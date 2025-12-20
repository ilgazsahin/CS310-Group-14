import 'package:firebase_auth/firebase_auth.dart';

/// Service class to handle Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up a new user with email and password
  /// Returns the UserCredential on success, throws FirebaseAuthException on error
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If it's a string error (from _handleAuthException), rethrow it
      if (e is String) {
        throw e;
      }
      // Otherwise, show the actual error for debugging
      throw 'An unexpected error occurred: ${e.toString()}. Please try again.';
    }
  }

  /// Sign in an existing user with email and password
  /// Returns the UserCredential on success, throws FirebaseAuthException on error
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If it's a string error (from _handleAuthException), rethrow it
      if (e is String) {
        throw e;
      }
      // Otherwise, show the actual error for debugging
      throw 'An unexpected error occurred: ${e.toString()}. Please try again.';
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Update user password
  /// Requires re-authentication for security
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'You must be logged in to update your password.';
      }

      if (user.email == null) {
        throw 'Email address not found. Cannot update password.';
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) {
        throw e;
      }
      throw 'Failed to update password: ${e.toString()}';
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly error messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email address. Please sign up first.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'configuration-not-found':
      case 'CONFIGURATION_NOT_FOUND':
        return 'Firebase Authentication is not properly configured. Please enable Email/Password authentication in Firebase Console.';
      default:
        // Check if the error message contains keywords that indicate wrong password
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('password') &&
            (errorMessage.contains('incorrect') ||
                errorMessage.contains('wrong') ||
                errorMessage.contains('invalid') ||
                errorMessage.contains('credential'))) {
          return 'Incorrect password. Please check your password and try again.';
        }
        // Check if it's a credential-related error
        if (errorMessage.contains('credential') &&
            (errorMessage.contains('incorrect') ||
                errorMessage.contains('invalid') ||
                errorMessage.contains('expired'))) {
          return 'Incorrect email or password. Please check your credentials and try again.';
        }
        // Return the actual error message with code for debugging
        return e.message ??
            'An authentication error occurred (${e.code}). Please try again.';
    }
  }
}
