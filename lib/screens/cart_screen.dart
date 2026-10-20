import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Scaffold(appBar: AppBar(title: const Text('Shopping cart')),
      body: shop.cart.isEmpty ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_bag_outlined, size: 64), SizedBox(height: 12), Text('Your cart is empty')]))
      : ListView(padding: const EdgeInsets.all(16), children: [
        ...shop.cart.values.map((item) => Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 78, height: 78, child: item.product.imageUrl.isEmpty
            ? const Icon(Icons.watch, size: 38) : Image.network(item.product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.watch)))),
          const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text('Rs. ${item.product.price.toStringAsFixed(0)}'),
            Row(children: [IconButton(onPressed: () => shop.decrement(item.product.id), icon: const Icon(Icons.remove_circle_outline)),
              Text('${item.quantity}'), IconButton(onPressed: () => shop.add(item.product), icon: const Icon(Icons.add_circle_outline)),
              const Spacer(), IconButton(onPressed: () => shop.remove(item.product.id), icon: const Icon(Icons.delete_outline, color: Colors.red))]),
          ])),
        ])))),
        const SizedBox(height: 12), _line('Subtotal', shop.subtotal),
        _line('Delivery', 0), const Divider(), _line('Total', shop.subtotal, bold: true),
        const SizedBox(height: 18), ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())), child: const Text('Proceed to checkout')),
        const Padding(padding: EdgeInsets.only(top: 8), child: Text('Delivery charges are currently set to Rs. 0. Configure your delivery policy before launch.', style: TextStyle(color: Colors.grey, fontSize: 12))),
      ]),
    );
  }
  Widget _line(String label, double value, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
    Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    const Spacer(), Text('Rs. ${value.toStringAsFixed(0)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 18 : 14)),
  ]));
}
