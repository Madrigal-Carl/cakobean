import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/auth.dart';
import '../data/repositories/auth_repository.dart';

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
      await ref.read(authRepositoryProvider).signInWithEmail(
        email: email,
        password: password,
      );
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
  }) async {
    state = const AuthState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
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

  /// Clears a stale error (e.g. after the user edits a field).
  void clearError() {
    if (state.error != null) state = const AuthState();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
