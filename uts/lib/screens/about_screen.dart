import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          radius: 35,
          child: Icon(Icons.shopping_bag_outlined, size: 34),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Kenalan dengan\nKatalogKu.',
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 16),
      const Text(
        'Temukan informasi produk, bandingkan harga dan rating, lalu simpan '
        'produk yang menarik ke daftar favorit.',
        style: TextStyle(height: 1.6),
      ),
      const SizedBox(height: 24),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tentang data',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Produk berasal dari data contoh DummyJSON. Katalog ini adalah '
                'aplikasi pembelajaran dan tidak melayani transaksi pembelian.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Harga diberi label USD untuk demo. Nilai ditampilkan langsung '
                'dari API tanpa konversi rupiah atau perhitungan diskon tambahan.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Favorit disimpan sementara dan akan kosong ketika aplikasi dimulai ulang. '
                'Koneksi internet tetap diperlukan '
                'untuk mengambil informasi dan gambar produk.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text('Sumber data', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const SelectableText('https://dummyjson.com/products'),
      const SizedBox(height: 24),
      const Text(
        'KatalogKu 1.0.0\nUTS Pemrograman Mobile',
        style: TextStyle(color: Colors.black54, height: 1.6),
      ),
    ],
  );
}
