import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/store_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController(), phone = TextEditingController(), address = TextEditingController(), city = TextEditingController();
  bool loading = true, saving = false;
  String email = '';
  @override void initState() { super.initState(); load(); }
  @override void dispose() { name.dispose(); phone.dispose(); address.dispose(); city.dispose(); super.dispose(); }
  Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser!;
    email = user.email ?? '';
    final data = await StoreService().getUser(user.uid);
    name.text = data?['name'] ?? user.displayName ?? '';
    phone.text = data?['phone'] ?? ''; address.text = data?['address'] ?? ''; city.text = data?['city'] ?? '';
    if (mounted) setState(() => loading = false);
  }
  Future<void> save() async {
    setState(() => saving = true);
    try {
      await StoreService().updateUser(FirebaseAuth.instance.currentUser!.uid, {
        'name': name.text.trim(), 'phone': phone.text.trim(),
        'address': address.text.trim(), 'city': city.text.trim(),
      });
      await FirebaseAuth.instance.currentUser!.updateDisplayName(name.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => saving = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('My profile')),
    body: loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)), const SizedBox(height: 8),
      Center(child: Text(email, style: const TextStyle(color: Colors.grey))), const SizedBox(height: 20),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
      const SizedBox(height: 12), TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
      const SizedBox(height: 12), TextField(controller: address, decoration: const InputDecoration(labelText: 'Shipping address'), maxLines: 2),
      const SizedBox(height: 12), TextField(controller: city, decoration: const InputDecoration(labelText: 'City')),
      const SizedBox(height: 18), ElevatedButton(onPressed: saving ? null : save, child: saving ? const CircularProgressIndicator() : const Text('SAVE PROFILE')),
      const SizedBox(height: 10), OutlinedButton.icon(onPressed: () => AuthService().logout(), icon: const Icon(Icons.logout), label: const Text('Log out')),
    ]));
}
