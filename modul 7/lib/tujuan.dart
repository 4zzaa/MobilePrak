import 'package:flutter/material.dart';

class TujuanPage extends StatelessWidget {
  const TujuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text("halaman tujuan",
      style: TextStyle(color: Colors.white),
      ),backgroundColor: Colors.blue),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/kelapa.jpeg',
                  width: 190,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Pertama, kita perlu membuat dua halaman atau "routes" '
                  'yang ingin kita tampilkan. Selanjutnya, kita gunakan '
                  'perintah Navigator.push() untuk berpindah dari halaman '
                  'pertama ke halaman kedua. Ini seperti kita membuka '
                  'halaman baru. Terakhir, kita bisa kembali dari halaman '
                  'kedua ke halaman pertama menggunakan Navigator.pop(). '
                  'Seperti menutup halaman kedua dan kembali ke halaman pertama.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
                onPressed: (){
                Navigator.pop(context);
                },
                child: const Text(
                    "kembali ke home",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
