import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/store_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override State<SupportScreen> createState() => _SupportScreenState();
}
class _SupportScreenState extends State<SupportScreen> {
  final subject = TextEditingController(), message = TextEditingController();
  bool busy = false;
  @override void dispose() { subject.dispose(); message.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Customer support')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Frequently asked questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const ExpansionTile(title: Text('How can I track my order?'), children: [ListTile(title: Text('Open the Orders tab to view your order status.'))]),
      const ExpansionTile(title: Text('Can I change my shipping address?'), children: [ListTile(title: Text('Update your address in Profile before placing an order. Contact support for existing orders.'))]),
      const ExpansionTile(title: Text('Which payment methods are supported?'), children: [ListTile(title: Text('Cash on Delivery and manual bank transfer are available in this starter app.'))]),
      const Divider(height: 30), const Text('Contact us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
      const SizedBox(height: 12), TextField(controller: message, maxLines: 5, decoration: const InputDecoration(labelText: 'Describe your issue')),
      const SizedBox(height: 14), ElevatedButton(onPressed: busy ? null : () async {
        if (subject.text.trim().isEmpty || message.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill both fields'))); return;
        }
        setState(() => busy = true);
        try {
          final u = FirebaseAuth.instance.currentUser!;
          await StoreService().sendSupport(u.uid, u.email ?? '', subject.text, message.text);
          subject.clear(); message.clear();
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support request submitted')));
        } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
        finally { if (mounted) setState(() => busy = false); }
      }, child: busy ? const CircularProgressIndicator() : const Text('SEND MESSAGE')),
    ]));
}
