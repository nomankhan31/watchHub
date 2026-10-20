import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/watch_product.dart';

class StoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<WatchProduct>> watchProducts() => _db.collection('products')
    .where('active', isEqualTo: true).snapshots()
    .map((s) => s.docs.map((d) => WatchProduct.fromMap(d.id, d.data())).toList());

  Future<List<WatchProduct>> getProductsOnce() async {
    final s = await _db.collection('products').where('active', isEqualTo: true).get();
    return s.docs.map((d) => WatchProduct.fromMap(d.id, d.data())).toList();
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final d = await _db.collection('users').doc(uid).get();
    return d.data();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
    _db.collection('users').doc(uid).set(data, SetOptions(merge: true));

  Stream<List<Map<String, dynamic>>> userOrders(String uid) => _db.collection('orders')
    .where('userId', isEqualTo: uid).snapshots().map((s) {
      final list = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      list.sort((a, b) => ((b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0)
        .compareTo((a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
      return list;
    });

  Future<void> placeOrder({
    required String uid, required String name, required String phone,
    required String address, required String city, required String payment,
    required List<Map<String, dynamic>> items, required double total,
  }) async {
    await _db.collection('orders').add({
      'userId': uid, 'customerName': name, 'phone': phone,
      'address': address, 'city': city, 'paymentMethod': payment,
      'items': items, 'total': total, 'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> wishlist(String uid) => _db.collection('users')
    .doc(uid).collection('wishlist').snapshots()
    .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Future<void> toggleWishlist(String uid, WatchProduct p) async {
    final ref = _db.collection('users').doc(uid).collection('wishlist').doc(p.id);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.delete();
    } else {
      await ref.set({'productId': p.id, ...p.toMap(), 'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> submitReview(String uid, String productId, String userName, int rating, String comment) async {
    await _db.collection('products').doc(productId).collection('reviews').add({
      'userId': uid, 'userName': userName, 'rating': rating,
      'comment': comment.trim(), 'createdAt': FieldValue.serverTimestamp(),
      'helpful': 0,
    });
  }

  Stream<List<Map<String, dynamic>>> reviews(String productId) => _db.collection('products')
    .doc(productId).collection('reviews').snapshots().map((s) =>
      s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Future<void> sendSupport(String uid, String email, String subject, String message) =>
    _db.collection('supportTickets').add({
      'userId': uid, 'email': email, 'subject': subject,
      'message': message, 'status': 'Open', 'createdAt': FieldValue.serverTimestamp(),
    });
}
