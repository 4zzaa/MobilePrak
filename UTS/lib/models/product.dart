class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
    this.brand = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final price = json['price'];
    if (id is! int || title is! String || price is! num || price < 0) {
      throw const FormatException('Data produk tidak valid.');
    }
    String text(String key) => json[key] is String ? json[key] as String : '';
    return Product(
      id: id,
      title: title,
      description: text('description'),
      category: text('category'),
      brand: text('brand'),
      price: price.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: text('thumbnail'),
      images: (json['images'] as List?)?.whereType<String>().toList() ?? [],
    );
  }

  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;

  // DummyJSON mengembalikan harga dalam USD, bukan rupiah.
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get categoryLabel => category.replaceAll('-', ' ');
}
