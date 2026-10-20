import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  final email = TextEditingController();
  final password = TextEditingController();

  bool busy = false, hide = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_form.currentState!.validate()) return;

    setState(() => busy = true);

    try {
      await AuthService().login(
        email.text.trim(),
        password.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _message(e.message ?? 'Login failed');
      }
    } catch (_) {
      if (mounted) {
        _message('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  void _message(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.watch,
                      color: Color(0xFFD6AD60),
                      size: 74,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'WatchHub',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      'TIMELESS STYLE. EVERY DAY.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD6AD60),
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          v == null ||
                                  !RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(v.trim())
                              ? 'Enter a valid email'
                              : null,
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: password,
                      obscureText: hide,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => hide = !hide);
                          },
                          icon: Icon(
                            hide
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          if (email.text.trim().isEmpty) {
                            _message('Enter your email first.');
                            return;
                          }

                          try {
                            await AuthService().resetPassword(
                              email.text.trim(),
                            );

                            if (mounted) {
                              _message('Password reset email sent.');
                            }
                          } catch (e) {
                            if (mounted) {
                              _message(e.toString());
                            }
                          }
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Color(0xFFD6AD60),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: busy ? null : login,
                      child: busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('LOG IN'),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'New to WatchHub? Create account',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}