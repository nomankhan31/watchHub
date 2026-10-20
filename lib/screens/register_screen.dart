import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), password = TextEditingController();
  bool busy = false, hide = true;
  @override void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try { await AuthService().register(name.text, email.text, password.text); if (mounted) Navigator.pop(context); }
    on FirebaseAuthException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Registration failed'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create account')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440),
      child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.watch, size: 60, color: Color(0xFFD6AD60)), const SizedBox(height: 20),
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
          validator: (v) => v == null || v.trim().length < 2 ? 'Enter your name' : null),
        const SizedBox(height: 14),
        TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
        const SizedBox(height: 14),
        TextFormField(controller: password, obscureText: hide, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(onPressed: () => setState(() => hide = !hide), icon: Icon(hide ? Icons.visibility : Icons.visibility_off))),
          validator: (v) => v == null || v.length < 6 ? 'Use at least 6 characters' : null),
        const SizedBox(height: 22),
        ElevatedButton(onPressed: busy ? null : submit, child: busy ? const CircularProgressIndicator() : const Text('CREATE ACCOUNT')),
      ]))))));
}
