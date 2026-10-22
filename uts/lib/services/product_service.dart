import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductService {
  ProductService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw ApiException(
          response.statusCode == 404
              ? 'Produk tidak ditemukan di server.'
              : 'Server mengembalikan HTTP ${response.statusCode}. Coba lagi.',
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respons bukan objek JSON.');
      }
      return decoded;
    } on TimeoutException {
      throw const ApiException(
        'Koneksi terlalu lama. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung. Periksa koneksi internet kamu.',
      );
    } on FormatException {
      throw const ApiException(
        'Respons server tidak dapat dibaca. Coba lagi nanti.',
      );
    }
  }

  Future<List<Product>> fetchProducts() async {
    final json = await _get(
      Uri.https('dummyjson.com', '/products', {'limit': '0'}),
    );
    try {
      final items = json['products'];
      if (items is! List) throw const FormatException('products bukan daftar.');
      return items
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on FormatException {
      throw const ApiException(
        'Struktur data produk tidak sesuai. Coba lagi nanti.',
      );
    } on TypeError {
      throw const ApiException(
        'Tipe data produk tidak sesuai. Coba lagi nanti.',
      );
    }
  }

  Future<Product> fetchProduct(int id) async {
    final json = await _get(Uri.https('dummyjson.com', '/products/$id'));
    try {
      return Product.fromJson(json);
    } on FormatException {
      throw const ApiException('Data detail produk tidak sesuai.');
    } on TypeError {
      throw const ApiException('Tipe data detail produk tidak sesuai.');
    }
  }

  void dispose() => _client.close();
}
