import '../models/product.dart';

enum ProductSort {
  recommended('Urutan awal'),
  priceAscending('Harga terendah'),
  priceDescending('Harga tertinggi'),
  rating('Rating tertinggi');

  const ProductSort(this.label);
  final String label;
}

List<Product> filterProducts(
  List<Product> products, {
  String query = '',
  String? category,
  ProductSort sort = ProductSort.recommended,
}) {
  final q = query.trim().toLowerCase();
  final result = products
      .where(
        (p) =>
            (category == null || p.category == category) &&
            (q.isEmpty ||
                '${p.title} ${p.brand} ${p.category}'.toLowerCase().contains(
                  q,
                )),
      )
      .toList();
  switch (sort) {
    case ProductSort.recommended:
      break;
    case ProductSort.priceAscending:
      result.sort((a, b) => a.price.compareTo(b.price));
    case ProductSort.priceDescending:
      result.sort((a, b) => b.price.compareTo(a.price));
    case ProductSort.rating:
      result.sort((a, b) => b.rating.compareTo(a.rating));
  }
  return result;
}

String categoryLabel(String slug) => slug.isEmpty
    ? 'Lainnya'
    : slug
          .split('-')
          .map(
            (part) => part.isEmpty
                ? ''
                : '${part[0].toUpperCase()}${part.substring(1)}',
          )
          .join(' ');

String priceLabel(double price) => 'USD ${price.toStringAsFixed(2)}';
