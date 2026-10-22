class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.description = '',
    this.category = '',
    this.brand = '',
    this.thumbnail = '',
    this.rating = 0,
    this.stock = 0,
    this.discountPercentage = 0,
    this.images = const [],
    this.warranty = '',
    this.shipping = '',
    this.returnPolicy = '',
    this.reviews = const [],
  });

  final int id;
  final String title, description, category, brand, thumbnail;
  final double price, rating, discountPercentage;
  final int stock;
  final List<String> images;
  final String warranty, shipping, returnPolicy;
  final List<ProductReview> reviews;

  factory Product.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int ||
        json['title'] is! String ||
        json['price'] is! num ||
        (json['title'] as String).trim().isEmpty ||
        !(json['price'] as num).isFinite ||
        (json['price'] as num) < 0) {
      throw const FormatException('Data utama produk tidak valid.');
    }
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      warranty: json['warrantyInformation'] as String? ?? '',
      shipping: json['shippingInformation'] as String? ?? '',
      returnPolicy: json['returnPolicy'] as String? ?? '',
      reviews: (json['reviews'] as List? ?? [])
          .map((item) => ProductReview.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ProductReview {
  const ProductReview({
    required this.name,
    required this.comment,
    required this.rating,
  });

  final String name, comment;
  final double rating;

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
    name: json['reviewerName'] as String? ?? 'Pengguna',
    comment: json['comment'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
  );
}
