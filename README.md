# MobilePrak

Repositori praktikum Pemrograman Mobile. Aplikasi UTS berada di folder
**[UTS — MONO Store](UTS/README.md)**; folder modul praktikum sebelumnya tetap tersedia.

## Aplikasi UTS: MONO Store

Katalog produk Flutter/Dart dengan data dinamis dari
[DummyJSON Products](https://dummyjson.com/products). Tampilan menggunakan tema
hitam-putih, logo impor Google Material Icons, dan tidak menggunakan dependensi
`cupertino_icons`.

Fitur utama: katalog, pencarian, filter kategori, urutan harga/rating, detail dan
galeri produk, favorit, serta keranjang simulasi dengan batas stok.
`FutureBuilder` mengatur status loading, berhasil, dan error/retry.

Teknologi: Flutter, Dart, package `http`, Material Icons dari SDK, `flutter_test`,
dan `flutter_lints`. Toolchain yang diverifikasi adalah Flutter 3.47.7, Dart
3.13.5, JDK 21, dan Android SDK 36.

```sh
git clone https://github.com/4zzaa/MobilePrak.git
cd MobilePrak/UTS
flutter pub get --enforce-lockfile
flutter run
```

Siapkan emulator atau perangkat Android yang mendukung minimal API 24.
Dokumentasi lengkap, struktur kode, langkah build, dan ketentuan UTS ada di
[README aplikasi](UTS/README.md).

Validasi akhir: 22 tes otomatis lulus, analisis statis bersih, API asli berhasil
diakses, serta build web dan APK debug ARM64 berhasil. APK belum diuji di
ponsel fisik. Favorit dan keranjang hanya tersimpan selama sesi aplikasi.

Lihat [draf laporan PDF](UTS/docs/Laporan_UTS_MONO_Store_DRAF.pdf) dan
[bukti pengujian](UTS/docs/hasil_pengujian.txt). Identitas serta logo fakultas pada
cover perlu dilengkapi sebelum laporan diunggah ke Google Drive.
