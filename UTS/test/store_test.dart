import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_store/main.dart';
import 'package:uts_store/models/product.dart';
import 'package:uts_store/services/product_service.dart';

const product = Product(
  id: 1,
  title: 'Tas Mono',
  description: 'Tas untuk kuliah.',
  category: 'bags',
  price: 20,
  rating: 4.5,
  stock: 1,
  thumbnail: '',
  images: [],
);
const secondProduct = Product(
  id: 2,
  title: 'Jam Mono',
  description: 'Jam tangan.',
  category: 'watches',
  price: 50,
  rating: 4,
  stock: 0,
  thumbnail: '',
  images: [],
);

class FakeProductService extends ProductService {
  bool shouldFail = false;
  int calls = 0;
  List<Product> products = [product, secondProduct];
  Completer<List<Product>>? pending;
  @override
  Future<List<Product>> fetchProducts() async {
    calls++;
    if (pending != null) return pending!.future;
    if (shouldFail) throw const ProductApiException('Koneksi terputus.');
    return products;
  }
}

void main() {
  late FakeProductService service;
  setUp(() => service = FakeProductService());
  tearDown(() => service.dispose());

  Future<void> start(
    WidgetTester tester, {
    Size size = const Size(800, 1200),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(UtsStoreApp(service: service));
    await tester.pumpAndSettle();
  }

  testWidgets('FutureBuilder menampilkan loading lalu sukses', (tester) async {
    service.pending = Completer<List<Product>>();
    await tester.pumpWidget(UtsStoreApp(service: service));
    expect(find.byType(FutureBuilder<List<Product>>), findsOneWidget);
    expect(find.text('Mengambil produk…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    service.pending!.complete([product]);
    await tester.pumpAndSettle();
    expect(find.text('Mengambil produk…'), findsNothing);
    expect(find.text('1 produk'), findsOneWidget);
  });

  testWidgets('FutureBuilder menampilkan error dari future yang gagal',
      (tester) async {
    service.pending = Completer<List<Product>>();
    await tester.pumpWidget(UtsStoreApp(service: service));
    service.pending!
        .completeError(const ProductApiException('API tidak tersedia.'));
    await tester.pumpAndSettle();
    expect(find.text('API tidak tersedia.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.text('Mengambil produk…'), findsNothing);
  });

  testWidgets('rebuild pencarian dan navigasi tidak mengulang request API',
      (tester) async {
    await start(tester);
    expect(service.calls, 1);
    await tester.enterText(find.byType(TextField), 'tas');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Katalog'));
    await tester.pumpAndSettle();
    expect(service.calls, 1);
    await tester.tap(find.byTooltip('Muat ulang produk'));
    await tester.pumpAndSettle();
    expect(service.calls, 2);
  });

  testWidgets('respons API kosong menampilkan kondisi kosong', (tester) async {
    service.products = [];
    await start(tester);
    expect(find.text('0 produk'), findsOneWidget);
    expect(find.text('Produk tidak ditemukan'), findsOneWidget);
    expect(find.text('Produk belum bisa dimuat'), findsNothing);
  });

  testWidgets('memuat katalog, mencari, dan menangani hasil kosong', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Tas Mono'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'jam');
    await tester.pumpAndSettle();
    expect(find.text('Tas Mono'), findsNothing);
    expect(find.text('Jam Mono'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pumpAndSettle();
    expect(find.text('Produk tidak ditemukan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter kategori dan urutan harga bekerja', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('Urutkan produk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Harga tertinggi'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Jam Mono')).dx,
      lessThan(tester.getTopLeft(find.text('Tas Mono')).dx),
    );
    await tester.tap(find.text('Semua kategori'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('bags').last);
    await tester.pumpAndSettle();
    expect(find.text('Jam Mono'), findsNothing);
    expect(find.text('Tas Mono'), findsOneWidget);
  });

  testWidgets('membuka detail dan menambahkan produk ke keranjang', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Tas Mono'));
    await tester.pumpAndSettle();
    expect(find.text('Tas untuk kuliah.'), findsOneWidget);
    await tester.ensureVisible(find.text('Tambah ke keranjang'));
    await tester.tap(find.text('Tambah ke keranjang'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Total (USD)'), findsOneWidget);
    expect(find.text('\$20.00'), findsNWidgets(2));
    expect(
      tester
          .widget<IconButton>(find.byWidgetPredicate(
            (widget) =>
                widget is IconButton && widget.tooltip == 'Tambah Tas Mono',
          ))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byTooltip('Kurangi Tas Mono'));
    await tester.pumpAndSettle();
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
  });

  testWidgets('menyimpan dan menghapus favorit', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('Tambah favorit').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Tas Mono'), findsOneWidget);
    expect(find.text('Jam Mono'), findsNothing);
    await tester.tap(find.byTooltip('Hapus favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada favorit'), findsOneWidget);
  });

  testWidgets('retry setelah koneksi gagal', (tester) async {
    service.shouldFail = true;
    await start(tester);
    expect(find.text('Koneksi terputus.'), findsOneWidget);
    service.shouldFail = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Tas Mono'), findsOneWidget);
  });

  testWidgets('refresh gagal mempertahankan katalog', (tester) async {
    await start(tester);
    service.shouldFail = true;
    await tester.tap(find.byTooltip('Muat ulang produk'));
    await tester.pumpAndSettle();
    expect(find.text('Tas Mono'), findsOneWidget);
    expect(find.text('Koneksi terputus.'), findsOneWidget);
  });

  testWidgets('layout ponsel sempit tidak overflow', (tester) async {
    await start(tester, size: const Size(320, 800));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Tas Mono'));
    await tester.tap(find.text('Tas Mono'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
