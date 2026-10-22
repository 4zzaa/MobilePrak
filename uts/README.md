# KatalogKu

Aplikasi katalog produk berbasis Flutter dan Dart yang terintegrasi dengan API DummyJSON. Aplikasi ini dibuat untuk tugas UTS Mobile Programming dan menggunakan tampilan hitam, putih, serta abu-abu. Foto produk mengikuti gambar dari API.

## Identitas

- Nama: Hilmi Aziz
- NIM: 240605110119
- Kelas: Mobile Programming H
- Program studi: Teknik Informatika
- Universitas: Universitas Islam Negeri Maulana Malik Ibrahim Malang

## Fitur

- Menampilkan katalog beserta foto, nama, kategori, harga, rating, dan stok produk.
- Mencari produk berdasarkan judul, merek, atau kategori tanpa membedakan huruf besar dan kecil.
- Memfilter produk berdasarkan kategori.
- Mengurutkan produk berdasarkan urutan awal, harga terendah, harga tertinggi, atau rating tertinggi.
- Menampilkan detail produk, galeri gambar, deskripsi, dan informasi tambahan dari API.
- Menandai dan menghapus produk favorit selama sesi aplikasi berjalan.
- Memuat ulang katalog melalui tombol atau tarikan layar.
- Menampilkan indikator pemuatan, pesan kegagalan dengan tombol coba lagi, serta keadaan daftar kosong.
- Menyediakan navigasi Katalog, Favorit, dan Tentang.

## Teknologi

| Komponen | Penggunaan |
| --- | --- |
| Flutter dan Dart | Antarmuka dan logika aplikasi |
| `http` | Permintaan HTTP ke API |
| `dart:convert` | Dekode respons JSON |
| `FutureBuilder` | Tampilan berdasarkan keadaan pengambilan data |
| `ChangeNotifier` | Notifikasi perubahan favorit |
| Material Icons | Ikon bawaan Flutter, termasuk ikon toko |

Package tambahan hanya `http`. Versi ini tidak menggunakan `shared_preferences` atau `cupertino_icons`.

## API

Sumber data: [DummyJSON Products](https://dummyjson.com/docs/products).

| Metode | Endpoint | Fungsi |
| --- | --- | --- |
| GET | `https://dummyjson.com/products?limit=0` | Mengambil seluruh daftar produk untuk katalog dan pencarian lokal |
| GET | `https://dummyjson.com/products/{id}` | Mengambil detail produk berdasarkan ID |

Respons katalog memiliki properti `products` berupa daftar objek. Setiap objek dikonversi menjadi `Product` melalui `Product.fromJson`. Permintaan memiliki batas waktu 20 detik. Layanan memeriksa status HTTP dan menangani kegagalan jaringan, timeout, serta format data yang tidak sesuai.

## Struktur kode

| File di dalam `lib/` | Tanggung jawab |
| --- | --- |
| `main.dart` | Menjalankan aplikasi, mengatur tema, dan menyediakan layanan serta controller |
| `models/product.dart` | Model `Product`, `ProductReview`, dan pemetaan JSON |
| `services/product_service.dart` | Permintaan katalog dan detail serta penanganan kesalahan API |
| `state/favorites_controller.dart` | Daftar ID produk favorit di memori |
| `screens/home_screen.dart` | Katalog, pencarian, filter, pengurutan, dan navigasi utama |
| `screens/detail_screen.dart` | Tampilan detail produk |
| `screens/about_screen.dart` | Informasi aplikasi |
| `widgets/product_card.dart` | Kartu produk |
| `widgets/product_image.dart` | Gambar produk dan tampilan pengganti saat gagal |
| `widgets/favorite_button.dart` | Tombol favorit |
| `widgets/async_states.dart` | Komponen pemuatan dan pesan keadaan layar |
| `utils/product_filter.dart` | Pencarian, filter, pengurutan, serta format kategori dan harga |

## Persiapan dan cara menjalankan

Gunakan project Flutter yang sudah tersedia. Jika menggunakan ZIP folder `lib`, ekstrak isinya sehingga file utama berada di `lib/main.dart`, bukan `lib/lib/main.dart`.

1. Pastikan Flutter SDK, Android SDK, serta emulator atau perangkat Android sudah disiapkan.
2. Buka folder utama project yang berisi `pubspec.yaml`.
3. Sesuaikan bagian berikut pada `pubspec.yaml`. Gabungkan dengan bagian yang sudah ada; jangan membuat dua bagian `dependencies` atau dua bagian `flutter` yang sama pada tingkat indentasi yang sama.

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     http: ^1.4.0

   flutter:
     uses-material-design: true
   ```

   Pertahankan konfigurasi project lainnya, termasuk `name`, `environment`, dan `dev_dependencies` jika digunakan. `http` sejajar dengan `flutter` di bawah `dependencies`, bukan diletakkan di bawah `sdk: flutter`.

4. Untuk Android, pastikan `android/app/src/main/AndroidManifest.xml` memiliki izin berikut sebagai anak elemen `<manifest>`, di luar `<application>`. Jika sudah ada, tidak perlu ditambahkan lagi.

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

5. Jalankan perintah berikut dari terminal pada folder utama project:

   ```bash
   flutter pub get
   flutter run
   ```

6. Pilih perangkat jika diminta, lalu pastikan perangkat memiliki koneksi internet untuk mengambil produk dan gambar.

## Cara menggunakan

1. Buka tab **Katalog** dan tunggu data selesai dimuat.
2. Ketik kata kunci pada kolom pencarian atau pilih kategori.
3. Gunakan pilihan pengurutan untuk membandingkan harga atau rating.
4. Tekan kartu produk untuk membuka detail. Tekan panah kembali untuk kembali ke katalog.
5. Tekan ikon hati untuk menandai produk, lalu lihat hasilnya pada tab **Favorit**. Tekan kembali ikon hati untuk menghapus tanda.
6. Tekan tombol muat ulang atau tarik daftar ke bawah untuk memperbarui data.
7. Jika permintaan gagal, periksa koneksi dan tekan **Coba lagi**.

## Alur pengambilan data

`HomeScreen` memanggil `ProductService.fetchProducts()` melalui `initState` dan menyimpan hasilnya sebagai `Future`. Layanan mengirim GET, memeriksa status respons, mendekode JSON, lalu membentuk daftar `Product`. `FutureBuilder` menampilkan keadaan memuat, gagal, atau berhasil.

Pencarian, filter, dan pengurutan dilakukan pada daftar yang sudah dimuat sehingga tidak mengirim permintaan baru setiap kali pengguna mengetik. Halaman detail melakukan permintaan tersendiri berdasarkan ID produk. Favorit menggunakan `Set<int>` dan `ChangeNotifier` untuk memperbarui tampilan saat pilihan berubah.

## Batasan

- Favorit hanya disimpan di memori dan kembali kosong ketika aplikasi dimulai ulang.
- Pengambilan data dan gambar membutuhkan koneksi internet; belum tersedia penyimpanan katalog untuk penggunaan offline.
- Label USD merupakan konvensi tampilan demo. Aplikasi tidak melakukan konversi rupiah atau menghitung ulang potongan harga.
- Jumlah produk, kategori, dan isi katalog mengikuti respons API sehingga dapat berubah.
- Data merupakan data contoh untuk pembelajaran. Aplikasi tidak menyediakan keranjang, pembayaran, atau transaksi pembelian.

## Penempatan README

Simpan file ini dengan nama `README.md` pada folder utama project, sejajar dengan `pubspec.yaml` serta folder `lib` dan `android`. Jika sudah ada README bawaan Flutter, isi file tersebut dapat diganti dengan dokumentasi ini.

Saat mengunggah project ke GitHub, sertakan `README.md` bersama kode project. File ini menjelaskan aplikasi dan langkah menjalankannya kepada pembaca repositori.

## Referensi

- [Dokumentasi API produk DummyJSON](https://dummyjson.com/docs/products)
- [Flutter — Fetch data from the internet](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Flutter — FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [Package http](https://pub.dev/packages/http)
