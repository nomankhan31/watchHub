import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/store_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in.')));
    return Scaffold(appBar: AppBar(title: const Text('My orders')), body: StreamBuilder(
      stream: StoreService().userOrders(user.uid), builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Unable to load orders: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!;
        if (orders.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long, size: 60), SizedBox(height: 10), Text('No orders yet')]));
        return ListView.builder(padding: const EdgeInsets.all(12), itemCount: orders.length, itemBuilder: (_, i) {
          final o = orders[i]; final items = List<Map<String, dynamic>>.from(o['items'] ?? []);
          return Card(child: ExpansionTile(title: Text('Order #${(o['id'] as String).substring(0, 6).toUpperCase()}'),
            subtitle: Text('${o['status'] ?? 'Pending'} • Rs. ${o['total'] ?? 0}'),
            children: [...items.map((it) => ListTile(title: Text(it['name'] ?? 'Watch'), subtitle: Text('Qty: ${it['quantity'] ?? 1}'), trailing: Text('Rs. ${it['price'] ?? 0}'))),
              ListTile(title: const Text('Ship to'), subtitle: Text('${o['customerName'] ?? ''}, ${o['address'] ?? ''}, ${o['city'] ?? ''}\\n${o['phone'] ?? ''}')),
            ]));
        });
      },
    ));
  }
}
