import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/welcome_page.dart';
import '../screens/home_screen.dart';

/// Widget that handles authentication-based routing
/// Shows WelcomePage for logged-out users, HomeScreen for logged-in users
/// Uses AuthProvider to manage auth state across the app
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in, show home screen
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // If user is not logged in, show welcome page
        return const WelcomePage();
      },
    );
  }
}

