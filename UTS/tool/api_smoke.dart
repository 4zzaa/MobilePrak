import 'dart:io';

import 'package:uts_store/services/product_service.dart';

Future<void> main() async {
  final service = ProductService();
  try {
    final products = await service.fetchProducts();
    if (products.isEmpty || products.first.title.isEmpty) {
      throw StateError('API tidak mengembalikan produk.');
    }
    stdout.writeln(
      'API OK: ${products.length} produk; pertama: ${products.first.title} (${products.first.formattedPrice}).',
    );
  } finally {
    service.dispose();
  }
}
