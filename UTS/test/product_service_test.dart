import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uts_store/services/product_service.dart';

void main() {
  test(
    'mengambil semua produk melalui HTTPS dan membaca harga desimal',
    () async {
      final service = ProductService(
        client: MockClient((request) async {
          expect(request.url.scheme, 'https');
          expect(request.url.host, 'dummyjson.com');
          expect(request.url.path, '/products');
          expect(request.url.queryParameters['limit'], '0');
          return http.Response(
            jsonEncode({
              'products': [
                {
                  'id': 1,
                  'title': 'Tas',
                  'price': 19.95,
                  'rating': 4,
                  'stock': 2,
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(service.dispose);
      final result = await service.fetchProducts();
      expect(result.single.title, 'Tas');
      expect(result.single.formattedPrice, '\$19.95');
      expect(result.single.rating, 4.0);
      expect(result.single.images, isEmpty);
    },
  );

  test('menerima katalog kosong tanpa menganggapnya sebagai error', () async {
    final service = ProductService(
      client: MockClient((_) async => http.Response('{"products":[]}', 200)),
    );
    addTearDown(service.dispose);
    expect(await service.fetchProducts(), isEmpty);
  });

  for (final status in [403, 404, 500]) {
    test('menampilkan status HTTP $status sebagai kegagalan', () async {
      final service = ProductService(
        client: MockClient((_) async => http.Response('error', status)),
      );
      addTearDown(service.dispose);
      await expectLater(
        service.fetchProducts(),
        throwsA(
          isA<ProductApiException>().having(
            (e) => e.message,
            'message',
            contains('$status'),
          ),
        ),
      );
    });
  }

  for (final body in [
    'not json',
    '{}',
    '{"products":[1]}',
    '{"products":[{"id":1,"title":"Tas","price":"invalid"}]}',
  ]) {
    test('menolak respons rusak: $body', () async {
      final service = ProductService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(service.dispose);
      await expectLater(
        service.fetchProducts(),
        throwsA(isA<ProductApiException>()),
      );
    });
  }

  test('menangani kegagalan koneksi', () async {
    final service = ProductService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.fetchProducts(),
      throwsA(
        isA<ProductApiException>().having(
          (e) => e.message,
          'message',
          contains('koneksi internet'),
        ),
      ),
    );
  });

  test('menangani timeout', () async {
    final service = ProductService(
      client: MockClient((_) async => throw TimeoutException('timeout')),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.fetchProducts(),
      throwsA(
        isA<ProductApiException>().having(
          (e) => e.message,
          'message',
          contains('terlalu lama'),
        ),
      ),
    );
  });
}
