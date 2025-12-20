import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Provider class to manage authentication state across the app
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state listener
  void _init() {
    // Set initial user
    _user = _authService.currentUser;
    _isLoading = false;
    notifyListeners();

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state will be updated automatically via stream listener
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state will be updated automatically via stream listener
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Auth state will be updated automatically via stream listener
    } catch (e) {
      rethrow;
    }
  }
}

