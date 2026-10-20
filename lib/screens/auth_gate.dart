import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: AuthService().authChanges,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(backgroundColor: Color(0xFF111111), body: Center(child: CircularProgressIndicator()));
      }
      final User? user = snapshot.data;
      return user == null ? const LoginScreen() : const HomeScreen();
    },
  );
}
