import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_product.dart';
import '../providers/shop_provider.dart';
import '../services/store_service.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please log in.'));
    return Scaffold(appBar: AppBar(title: const Text('Wishlist')), body: StreamBuilder(
      stream: StoreService().wishlist(user.uid), builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Could not load wishlist: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return const Center(child: Text('Your wishlist is empty'));
        return ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
          final item = items[i];
          final product = WatchProduct.fromMap(item['productId'] ?? item['id'], item);
          return ListTile(
            leading: SizedBox(width: 54, height: 54, child: (product.imageUrl.isEmpty)
              ? const Icon(Icons.watch) : Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.watch))),
            title: Text(product.name), subtitle: Text('Rs. ${product.price.toStringAsFixed(0)}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
            trailing: IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () async {
              await StoreService().toggleWishlist(user.uid, product);
              if (context.mounted) context.read<ShopProvider>().toggleWishlist(product.id);
            }));
        });
      },
    ));
  }
}
