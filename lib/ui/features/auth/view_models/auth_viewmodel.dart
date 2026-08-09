import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/data/repositories/auth_repository.dart';
import 'package:cakobean/domain/models/auth.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

/// Provides the single [AuthRepository] instance app-wide.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

/// Session state — emits the signed-in user (or null) whenever the auth
/// state changes. Watched by the router redirect and anywhere the UI needs
/// to know who's logged in.
final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).userStream,
);

/// UI-facing state for in-flight auth actions.
class AuthState {
  final bool isLoading;
  final String? error;
  final String? info;

  /// Set while an account was created but its email hasn't been confirmed
  /// with a code yet. When non-null, the register page shows the OTP step.
  final PendingRegistration? pendingRegistration;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.info,
    this.pendingRegistration,
  });
}

/// Details of a sign-up that is waiting for email confirmation.
class PendingRegistration {
  final String email;
  final String? firstName;
  final String? middleName;
  final String? lastName;

  const PendingRegistration({
    required this.email,
    this.firstName,
    this.middleName,
    this.lastName,
  });
}

/// ViewModel for all authentication actions. Pages call these methods and
/// reflect [state] (loading + error) — they never touch Supabase directly.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password);
      await _syncProfile();
      state = const AuthState();
      return true;
    } on AuthException catch (e) {
      state = AuthState(error: e.message);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .registerWithEmail(
            email: email,
            password: password,
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
          );
      await _syncProfile(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
      );
      state = const AuthState();
      return true;
    } on EmailConfirmationRequired catch (e) {
      // Account created but needs the emailed code — switch the page to the
      // OTP step (keeps the caller's fields so we can finish the sign-up).
      state = AuthState(
        pendingRegistration: PendingRegistration(
          email: e.email,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
        ),
      );
      return false;
    } on AuthException catch (e) {
      state = AuthState(error: e.message);
      return false;
    }
  }

  /// Verifies the code from the confirmation email and completes the
  /// pending sign-up.
  Future<bool> confirmRegistration({required String code}) async {
    final pending = state.pendingRegistration;
    if (pending == null) return false;
    state = AuthState(pendingRegistration: pending, isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .confirmRegistration(email: pending.email, code: code.trim());
      await _syncProfile(
        firstName: pending.firstName,
        middleName: pending.middleName,
        lastName: pending.lastName,
      );
      state = const AuthState();
      return true;
    } on AuthException catch (e) {
      state = AuthState(pendingRegistration: pending, error: e.message);
      return false;
    }
  }

  /// Re-sends the confirmation email when the user didn't receive the code.
  Future<bool> resendConfirmation() async {
    final pending = state.pendingRegistration;
    if (pending == null) return false;
    state = AuthState(pendingRegistration: pending, isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resendConfirmation(email: pending.email);
      state = AuthState(
        pendingRegistration: pending,
        info: 'A new code was sent to ${pending.email}.',
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState(pendingRegistration: pending, error: e.message);
      return false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState();
  }

  /// Writes the signed-in user's public profile to the Supabase `users`
  /// table so the app resolves their real identity instead of demo
  /// data. Runs inside the auth flow because the router bounces to /home as
  /// soon as auth state changes — a page's `context` may already be disposed
  /// by then, but this app-scoped `ref` always outlives navigation. Failures
  /// are non-fatal: auth is the source of truth for logging in.
  Future<void> _syncProfile({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    try {
      await ref
          .read(hubRepositoryProvider)
          .saveCurrentUser(
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
          );
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Profile sync failed (check RLS policies): $e');
    }
  }

  /// Clears stale error/info messages (e.g. after the user edits a field).
  /// Keeps the pending registration so the OTP step isn't lost.
  void clearError() {
    final state = this.state;
    if (state.error != null || state.info != null) {
      this.state = AuthState(pendingRegistration: state.pendingRegistration);
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
