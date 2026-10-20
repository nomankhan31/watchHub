import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_product.dart';
import '../providers/shop_provider.dart';
import '../services/store_service.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final WatchProduct product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int rating = 5;
  final comment = TextEditingController();

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    final images = p.imageUrls.isNotEmpty
        ? p.imageUrls
        : (p.imageUrl.isNotEmpty ? [p.imageUrl] : <String>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.brand),
        actions: [
          Consumer<ShopProvider>(
            builder: (_, shop, __) => IconButton(
              onPressed: () => shop.toggleWishlist(p.id),
              icon: Icon(
                shop.wishlistIds.contains(p.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: p.stock <= 0
                      ? null
                      : () {
                          context.read<ShopProvider>().add(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart'),
                            ),
                          );
                        },
                  child: const Text('Add to cart'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: p.stock <= 0
                      ? null
                      : () {
                          context.read<ShopProvider>().add(p);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                  child: const Text('Buy now'),
                ),
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 300,
            child: images.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFEFEFEF),
                    child: Icon(Icons.watch, size: 90),
                  )
                : PageView(
                    children: images.map((url) {
                      return InteractiveViewer(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.watch, size: 80),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 20),

          Text(
            p.brand.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            p.name,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFE7AD36),
              ),
              Text(
                ' ${p.rating.toStringAsFixed(1)}  •  ${p.reviewCount} reviews',
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Rs. ${p.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (p.oldPrice > p.price && p.oldPrice > 0)
            Text(
              'Rs. ${p.oldPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),

          const SizedBox(height: 8),

          Text(
            p.stock > 0
                ? 'In stock (${p.stock} available)'
                : 'Out of stock',
            style: TextStyle(
              color: p.stock > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Divider(height: 30),

          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            p.description.isEmpty
                ? 'A timeless watch made for everyday style.'
                : p.description,
          ),

          if (p.specifications.isNotEmpty) ...[
            const SizedBox(height: 20),

            const Text(
              'Specifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            ...p.specifications.map(
              (s) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(s),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],

          const Divider(height: 32),

          const Text(
            'Customer reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          StreamBuilder(
            stream: StoreService().reviews(p.id),
            builder: (context, snap) {
              if (snap.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Unable to load reviews.'),
                );
              }

              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                );
              }

              if (snap.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No reviews yet. Be the first!'),
                );
              }

              return Column(
                children: snap.data!.map<Widget>((r) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${r['userName'] ?? 'Customer'}',
                    ),
                    subtitle: Text(
                      '${r['comment'] ?? ''}',
                    ),
                    trailing: Text(
                      '⭐ ${r['rating'] ?? 0}',
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 12),

          const Text(
            'Write a review',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          DropdownButton<int>(
            value: rating,
            items: List.generate(
              5,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(
                  '${i + 1} star${i == 0 ? '' : 's'}',
                ),
              ),
            ),
            onChanged: (v) {
              if (v != null) {
                setState(() => rating = v);
              }
            },
          ),

          TextField(
            controller: comment,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience',
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please login to submit a review'),
                  ),
                );
                return;
              }

              if (comment.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Write a short comment first'),
                  ),
                );
                return;
              }

              try {
                await StoreService().submitReview(
                  user.uid,
                  p.id,
                  user.displayName ?? 'Customer',
                  rating,
                  comment.text.trim(),
                );

                comment.clear();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review submitted'),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Submit review'),
          ),
        ],
      ),
    );
  }
}
