import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/loading_widget.dart';
import '../../../services/firebase_auth_service.dart';
import '../../home/pages/main_navigation_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(
            message: 'Memeriksa akun...',
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationPage();
        }

        return const LoginPage();
      },
    );
  }
}