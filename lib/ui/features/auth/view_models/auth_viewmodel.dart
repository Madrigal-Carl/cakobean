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

  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// ViewModel for all authentication actions. Pages call these methods and
/// reflect [state] (loading + error) — they never touch Firebase directly.
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
    String? displayName,
    String? firstName,
    String? lastName,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .registerWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );
      await _syncProfile(firstName: firstName, lastName: lastName);
      state = const AuthState();
      return true;
    } on AuthException catch (e) {
      state = AuthState(error: e.message);
      return false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState();
  }

  /// Writes the signed-in user's public profile to the Firestore `users`
  /// collection so the app resolves their real identity instead of demo
  /// data. Runs inside the auth flow because the router bounces to /home as
  /// soon as auth state changes — a page's `context` may already be disposed
  /// by then, but this app-scoped `ref` always outlives navigation. Failures
  /// are non-fatal: auth is the source of truth for logging in.
  Future<void> _syncProfile({String? firstName, String? lastName}) async {
    try {
      await ref
          .read(hubRepositoryProvider)
          .saveCurrentUser(firstName: firstName, lastName: lastName);
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Profile sync failed (verify Firestore rules): $e');
    }
  }

  /// Clears a stale error (e.g. after the user edits a field).
  void clearError() {
    if (state.error != null) state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
