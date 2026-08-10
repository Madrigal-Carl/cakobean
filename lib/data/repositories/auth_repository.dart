import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:cakobean/data/services/auth_service.dart';
import 'package:cakobean/domain/models/auth.dart';

/// Thrown by [AuthRepository] with a human-friendly message for the UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Thrown by [AuthRepository.registerWithEmail] when the account was created
/// but the email still needs to be confirmed with a code. Carries the [email]
/// so the UI can run the OTP step without asking for it again.
class EmailConfirmationRequired extends AuthException {
  final String email;

  const EmailConfirmationRequired(this.email)
      : super('A code was sent to your email. Enter it to finish '
             'creating your account.');
}

/// Domain-facing repository over [AuthService]. Maps raw Supabase results into
/// [AuthUser] and translates errors to farmer-friendly text, keeping the UI
/// decoupled from Supabase. Swap the service implementation for another
/// provider later without touching UI code.
class AuthRepository {
  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  /// Emits the current user whenever the auth state changes (sign-in,
  /// sign-out, token refresh). The single source of truth for "am I logged in".
  Stream<AuthUser?> get userStream => _service.userStream;

  /// The user at this exact moment — useful for synchronous checks (routing).
  AuthUser? get currentUser => _service.currentUser;

  /// Logs in with email + password.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _service.signInWithEmail(
        email: email,
        password: password,
      );
      return AuthUser.fromSupabase(response.user)!;
    } on sb.AuthException catch (e) {
      throw AuthException(_messageFor(e.message));
    }
  }

  /// Creates a new account. Returns the signed-in user when the Supabase
  /// project has email confirmation disabled (sign-up completes instantly).
  /// When confirmation is enabled, throws [EmailConfirmationRequired] and the
  /// caller must run [confirmRegistration] with the code from the email.
  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? middleName,
    String? lastName,
    String? username,
  }) async {
    try {
      final response = await _service.registerWithEmail(
        email: email,
        password: password,
        metadata: {
          'first_name': firstName,
          'middle_name': middleName,
          'last_name': lastName,
          'username': username,
        },
      );
      if (response.session == null) {
        throw EmailConfirmationRequired(email);
      }
      return AuthUser.fromSupabase(response.user)!;
    } on sb.AuthException catch (e) {
      throw AuthException(_messageFor(e.message));
    }
  }

  /// Finishes a pending sign-up by verifying the code the user
  /// received by email. Returns the signed-in user on success.
  Future<AuthUser> confirmRegistration({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _service.verifySignupOtp(
        email: email,
        token: code,
      );
      if (response.session == null) {
        throw const AuthException(
          'The code was not accepted. Please try again.',
        );
      }
      return AuthUser.fromSupabase(response.user)!;
    } on sb.AuthException catch (e) {
      throw AuthException(_messageFor(e.message));
    }
  }

  /// Re-sends the sign-up confirmation email (with its code).
  Future<void> resendConfirmation({required String email}) async {
    try {
      await _service.resendSignupOtp(email);
    } on sb.AuthException catch (e) {
      throw AuthException(_messageFor(e.message));
    }
  }

  Future<void> signOut() => _service.signOut();

  /// Maps common Supabase auth errors to friendly, farmer-facing text.
  static String _messageFor(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('at least 6 characters')) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirm your email first, then log in.';
    }
    if (msg.contains('token has expired') ||
        msg.contains('invalid token') ||
        msg.contains('token is invalid')) {
      return 'That code is invalid or expired. Request a new one.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Too many attempts. Try again in a minute.';
    }
    if (msg.contains('error sending confirmation email') ||
        msg.contains('failed to send')) {
      return 'We could not send the confirmation email. Please try again in '
             'a few minutes.';
    }
    if (msg.contains('failed to fetch') || msg.contains('network')) {
      return 'No connection. Check your internet and try again.';
    }
    return message.isEmpty ? 'Something went wrong. Please try again.' : message;
  }
}
