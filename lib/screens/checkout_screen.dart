import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../services/store_service.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();

  String payment = 'Cash on Delivery';
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    city.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final shop = context.read<ShopProvider>();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place your order')),
      );
      return;
    }

    if (shop.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    setState(() => busy = true);

    try {
      await StoreService().placeOrder(
        uid: user.uid,
        name: name.text.trim(),
        phone: phone.text.trim(),
        address: address.text.trim(),
        city: city.text.trim(),
        payment: payment,
        items: shop.cart.values.map((i) => {
          'productId': i.product.id,
          'name': i.product.name,
          'brand': i.product.brand,
          'price': i.product.price,
          'quantity': i.quantity,
          'imageUrl': i.product.imageUrl,
        }).toList(),
        total: shop.subtotal,
      );

      shop.clearCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OrdersScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to place order. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? requiredText(String? v) =>
      v == null || v.trim().isEmpty
          ? 'This field is required'
          : null;

  @override
  Widget build(BuildContext context) {
    final total = context.watch<ShopProvider>().subtotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Delivery details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          Form(
            key: form,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                  ),
                  validator: requiredText,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                  ),
                  validator: requiredText,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: address,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Complete address',
                  ),
                  validator: requiredText,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: city,
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                  validator: requiredText,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Payment method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          RadioGroup<String>(
            groupValue: payment,
            onChanged: (value) {
              if (value != null) {
                setState(() => payment = value);
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  value: 'Cash on Delivery',
                  title: Text('Cash on Delivery'),
                ),
                RadioListTile<String>(
                  value: 'Bank Transfer',
                  title: Text('Bank Transfer (manual confirmation)'),
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            title: const Text('Order total'),
            trailing: Text(
              'Rs. ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: busy ? null : submit,
            child: busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('PLACE ORDER'),
          ),
        ],
      ),
    );
  }
}
