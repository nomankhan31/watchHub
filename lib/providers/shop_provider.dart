import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/watch_product.dart';

class ShopProvider extends ChangeNotifier {
  final Map<String, CartItem> _cart = {};
  final Set<String> _wishlist = {};
  String _query = '';
  String _brand = 'All';
  String _category = 'All';
  String _sort = 'Popular';
  double _maxPrice = 1000000;

  Map<String, CartItem> get cart => Map.unmodifiable(_cart);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlist);
  String get query => _query;
  String get brand => _brand;
  String get category => _category;
  String get sort => _sort;
  double get maxPrice => _maxPrice;
  int get itemCount => _cart.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _cart.values.fold(0, (sum, item) => sum + item.total);

  void add(WatchProduct p) {
    if (p.stock <= 0) return;
    if (_cart.containsKey(p.id)) {
      if (_cart[p.id]!.quantity < p.stock) _cart[p.id]!.quantity++;
    } else {
      _cart[p.id] = CartItem(product: p);
    }
    notifyListeners();
  }
  void decrement(String id) {
    if (!_cart.containsKey(id)) return;
    if (_cart[id]!.quantity <= 1) { _cart.remove(id); } else { _cart[id]!.quantity--; }
    notifyListeners();
  }
  void remove(String id) { _cart.remove(id); notifyListeners(); }
  void clearCart() { _cart.clear(); notifyListeners(); }
  void toggleWishlist(String id) {
    _wishlist.contains(id) ? _wishlist.remove(id) : _wishlist.add(id);
    notifyListeners();
  }
  void setQuery(String v) { _query = v; notifyListeners(); }
  void setBrand(String v) { _brand = v; notifyListeners(); }
  void setCategory(String v) { _category = v; notifyListeners(); }
  void setSort(String v) { _sort = v; notifyListeners(); }
  void setMaxPrice(double v) { _maxPrice = v; notifyListeners(); }

  List<WatchProduct> filter(List<WatchProduct> products) {
    var result = products.where((p) =>
      (p.name.toLowerCase().contains(_query.toLowerCase()) ||
       p.brand.toLowerCase().contains(_query.toLowerCase())) &&
      (_brand == 'All' || p.brand == _brand) &&
      (_category == 'All' || p.category == _category) &&
      p.price <= _maxPrice).toList();
    switch (_sort) {
      case 'Price: Low to High': result.sort((a,b) => a.price.compareTo(b.price)); break;
      case 'Price: High to Low': result.sort((a,b) => b.price.compareTo(a.price)); break;
      case 'Top Rated': result.sort((a,b) => b.rating.compareTo(a.rating)); break;
      default: result.sort((a,b) => b.reviewCount.compareTo(a.reviewCount));
    }
    return result;
  }
}
