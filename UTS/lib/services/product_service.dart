import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiException implements Exception {
  const ProductApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProductService {
  ProductService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(Uri.https('dummyjson.com', '/products', {'limit': '0'}))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ProductApiException(
          'Server mengembalikan HTTP ${response.statusCode}. Coba lagi nanti.',
        );
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic> || data['products'] is! List) {
        throw const FormatException('Daftar produk tidak ditemukan.');
      }
      return (data['products'] as List).map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Data produk tidak valid.');
        }
        return Product.fromJson(item);
      }).toList();
    } on TimeoutException {
      throw const ProductApiException(
        'Koneksi terlalu lama. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ProductApiException(
        'Tidak dapat terhubung. Periksa koneksi internet kamu.',
      );
    } on FormatException {
      throw const ProductApiException('Format data dari server tidak valid.');
    } on TypeError {
      throw const ProductApiException('Format data dari server tidak valid.');
    }
  }

  void dispose() => _client.close();
}
