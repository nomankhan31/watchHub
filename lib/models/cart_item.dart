import 'watch_product.dart';

class CartItem {
  final WatchProduct product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get total => product.price * quantity;
}
