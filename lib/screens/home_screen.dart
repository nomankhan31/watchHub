import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_product.dart';
import '../providers/shop_provider.dart';
import '../services/store_service.dart';
import '../widgets/watch_card.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import 'support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  final service = StoreService();
  @override Widget build(BuildContext context) {
    final pages = [
      _home(),
      const WishlistScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Row(children: [Icon(Icons.watch, color: Color(0xFFD6AD60)), SizedBox(width: 8), Text('WatchHub', style: TextStyle(fontWeight: FontWeight.bold))]),
        actions: [IconButton(tooltip: 'Support', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())), icon: const Icon(Icons.support_agent)),
          Consumer<ShopProvider>(builder: (_, shop, __) => Padding(padding: const EdgeInsets.only(right: 8), child: Badge(label: Text('${shop.itemCount}'),
            child: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())), icon: const Icon(Icons.shopping_bag_outlined)))))],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Wishlist'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ]),
    );
  }

  Widget _home() => StreamBuilder<List<WatchProduct>>(
    stream: service.watchProducts(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Could not load products. Check Firestore setup.\\n${snapshot.error}')));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final all = snapshot.data!;
      final shop = context.watch<ShopProvider>();
      final products = shop.filter(all);
      final brands = ['All', ...{for (final p in all) p.brand}];
      final categories = ['All', ...{for (final p in all) p.category}];
      return CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Container(
          padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(22)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('THE ART OF TIME', style: TextStyle(color: Color(0xFFD6AD60), letterSpacing: 2, fontSize: 11)),
            SizedBox(height: 8), Text('Find your\\nperfect watch.', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8), Text('Timeless pieces. Exceptional craftsmanship.', style: TextStyle(color: Colors.white70)),
          ]),
        ))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: TextField(
          onChanged: shop.setQuery, decoration: const InputDecoration(hintText: 'Search watches or brands', prefixIcon: Icon(Icons.search), suffixIcon: Icon(Icons.tune))))),
        SliverToBoxAdapter(child: SizedBox(height: 52, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
          children: categories.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(c), selected: shop.category == c, onSelected: (_) => shop.setCategory(c)))).toList()))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Row(children: [
          const Text('Discover watches', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(),
          DropdownButton<String>(value: shop.sort, underline: const SizedBox(), items: const [
            DropdownMenuItem(value: 'Popular', child: Text('Popular')), DropdownMenuItem(value: 'Top Rated', child: Text('Top rated')),
            DropdownMenuItem(value: 'Price: Low to High', child: Text('Price ↑')), DropdownMenuItem(value: 'Price: High to Low', child: Text('Price ↓')),
          ], onChanged: (v) { if (v != null) shop.setSort(v); }),
        ]))),
        SliverToBoxAdapter(child: SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
          children: brands.map((b) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: FilterChip(label: Text(b), selected: shop.brand == b, onSelected: (_) => shop.setBrand(b)))).toList()))),
        if (products.isEmpty) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(36), child: Center(child: Text('No watches found. Add products in Firestore or change filters.'))))
        else SliverPadding(padding: const EdgeInsets.all(12), sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, i) => WatchCard(product: products[i]), childCount: products.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .62, crossAxisSpacing: 12, mainAxisSpacing: 12),
        )),
      ]);
    },
  );
}
