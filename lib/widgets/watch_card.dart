import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_product.dart';
import '../providers/shop_provider.dart';
import '../screens/product_detail_screen.dart';

class WatchCard extends StatelessWidget {
  final WatchProduct product;
  const WatchCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final discount = product.oldPrice > product.price && product.oldPrice > 0
        ? ((product.oldPrice - product.price) / product.oldPrice * 100).round() : 0;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECECEC))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(children: [
            Positioned.fill(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: product.imageUrl.isEmpty
                ? const ColoredBox(color: Color(0xFFEFEFEF), child: Icon(Icons.watch, size: 64))
                : Image.network(product.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFEFEFEF), child: Icon(Icons.watch, size: 64))))),
            if (discount > 0) Positioned(left: 8, top: 8, child: Chip(label: Text('$discount% OFF'), visualDensity: VisualDensity.compact)),
            Positioned(right: 4, top: 4, child: IconButton.filledTonal(
              onPressed: () => shop.toggleWishlist(product.id),
              icon: Icon(shop.wishlistIds.contains(product.id) ? Icons.favorite : Icons.favorite_border),
            )),
          ])),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.brand.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 3),
            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.star, size: 15, color: Color(0xFFE7AD36)),
              Text(' ${product.rating.toStringAsFixed(1)} (${product.reviewCount})', style: const TextStyle(fontSize: 11))]),
            const SizedBox(height: 5),
            Text('Rs. ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (product.stock <= 0) const Text('Out of stock', style: TextStyle(color: Colors.red, fontSize: 11)),
          ])),
        ]),
      ),
    );
  }
}
