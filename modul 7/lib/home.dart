import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(title: const Text("Halaman Home",
          style: TextStyle(color: Colors.white),
      ), backgroundColor: Colors.red, ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
        'Banyak aplikasi memiliki beberapa layar untuk '
        'menampilkan informasi yang berbeda. Contohnya, '
          'ada layar produk, dan ketika pengguna mengklik '
          'produk, akan muncul layar dengan detail produk '
          'tersebut.',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/kelapa.jpeg',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const Text(
              'pertama, kita perlu membuat dua halaman atau "routes" yang ingin kita tampilkan. '
                  'selanjutnya, kita gunakan perintah Navigaotr.oush() untuk berpindah dari halaman pertama ke halaman kedua. ini seperti kita membukanhalamn baru',
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/tujuan');
              },
              child: const Text("Ke Halaman Tujuan"),
            ),
          ],
        ),
      ),
    );
  }
}