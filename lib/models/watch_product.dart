class WatchProduct {
  final String id, name, brand, category, description, imageUrl;
  final double price, oldPrice, rating;
  final int stock, reviewCount;
  final List<String> imageUrls, specifications;

  const WatchProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.oldPrice = 0,
    this.rating = 0,
    this.stock = 0,
    this.reviewCount = 0,
    this.imageUrls = const [],
    this.specifications = const [],
  });

  factory WatchProduct.fromMap(String id, Map<String, dynamic> data) => WatchProduct(
    id: id,
    name: data['name'] ?? 'Unnamed watch',
    brand: data['brand'] ?? 'Other',
    category: data['category'] ?? 'Watches',
    description: data['description'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    price: (data['price'] as num? ?? 0).toDouble(),
    oldPrice: (data['oldPrice'] as num? ?? 0).toDouble(),
    rating: (data['rating'] as num? ?? 0).toDouble(),
    stock: (data['stock'] as num? ?? 0).toInt(),
    reviewCount: (data['reviewCount'] as num? ?? 0).toInt(),
    imageUrls: List<String>.from(data['imageUrls'] ?? const []),
    specifications: List<String>.from(data['specifications'] ?? const []),
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'brand': brand, 'category': category,
    'description': description, 'imageUrl': imageUrl, 'price': price,
    'oldPrice': oldPrice, 'rating': rating, 'stock': stock,
    'reviewCount': reviewCount, 'imageUrls': imageUrls,
    'specifications': specifications, 'updatedAt': DateTime.now(),
  };
}
