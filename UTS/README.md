# MONO Store — UTS

Aplikasi Flutter/Dart Android dengan UI hitam-putih yang terintegrasi dengan
[DummyJSON Products](https://dummyjson.com/products). Proyek UTS berdiri sendiri;
modul praktikum sebelumnya tidak diubah.

![Tampilan MONO Store di layar ponsel](docs/preview.png)

## Fitur

- Katalog produk API, gambar, harga USD, rating, dan stok.
- Pencarian judul/merek/deskripsi, filter kategori, dan urutan harga/rating.
- Detail produk dan galeri foto yang bisa digeser.
- Favorit dan keranjang simulasi dengan batas stok dan perhitungan total.
- Pull-to-refresh, indikator loading, kondisi kosong, retry, dan fallback gambar.
- `FutureBuilder<List<Product>>` untuk status loading, sukses, dan error API.
- Layout responsif untuk ponsel maupun layar lebar.

Favorit dan keranjang berada di memori selama aplikasi terbuka. Tidak ada
checkout, pembayaran, login, atau perubahan data di server. Harga asli API
adalah USD; aplikasi tidak menganggapnya sebagai rupiah.

## Menjalankan di Android

Gunakan Flutter stable **3.47.7** (Dart **3.13.5**) untuk menyamai toolchain cloud,
Android SDK 36, dan JDK 21. Android Gradle Plugin proyek ini adalah 9.1.0.
Perangkat target minimal mengikuti Flutter SDK (Android API 24 pada versi ini).

Jalankan dari folder `UTS`, bukan dari salah satu folder modul sebelumnya:

```sh
cd UTS
flutter pub get --enforce-lockfile
flutter devices
flutter run
```

Aktifkan USB debugging atau jalankan emulator lewat Android Studio. Pastikan
perangkat memiliki koneksi internet. Izin `INTERNET` sudah berada di manifest
utama sehingga berlaku untuk APK debug dan release.

APK untuk uji coba lokal:

```sh
flutter build apk --debug --target-platform android-arm64
```

Hasil berada di `build/app/outputs/flutter-apk/app-debug.apk`. Untuk perangkat
dengan arsitektur berbeda, hapus opsi `--target-platform android-arm64`.
Konfigurasi release template masih memakai debug signing untuk pengujian;
publikasi Play Store memerlukan signing key milikmu.

## Logo dan dependensi

Logo launcher diimpor dari Google Material Design Icons. Logo pada header
menggunakan ikon bawaan dari import `package:flutter/material.dart`. Lihat
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) untuk sumber dan lisensinya.
Tidak ada dependensi atau import `cupertino_icons` di proyek UTS.
Dependensi aplikasi hanya Flutter dan `http`.

## Struktur kode

```text
lib/main.dart                  Entry point dan tema hitam-putih
lib/pages/store_page.dart      FutureBuilder, katalog, favorit, detail, keranjang
lib/models/product.dart        Model dan parsing produk
lib/services/product_service.dart  HTTP, timeout, dan validasi respons
lib/widgets/product_image.dart Gambar dengan loading dan fallback
test/                          Tes API dan widget
tool/api_smoke.dart             Pengecekan API asli
android/                       Konfigurasi dan logo launcher Android
web/                           Entry point web
docs/                          Bukti pengujian, screenshot, dan draf laporan
```

## Pengujian

```sh
flutter analyze
flutter test
dart --suppress-analytics run tool/api_smoke.dart
flutter build web --no-web-resources-cdn --no-tree-shake-icons
```

Tes otomatis tidak membutuhkan akses API karena menggunakan HTTP client palsu.
Skrip `api_smoke.dart` menggunakan API asli dan akan gagal jika API tidak dapat
diakses atau tidak mengembalikan produk. API tidak memerlukan API key.

## Cloud environment

Toolchain berada di `/workspace/toolchains`, di luar checkout aplikasi. Untuk
terminal baru di cloud:

```sh
cd /workspace/MobilePrak/UTS
source tool/cloud_env.sh
```

`tool/setup_cloud.sh` memasang toolchain yang dipin, memverifikasi checksum
Android command-line tools, mengambil dependensi dari lockfile, dan menjalankan
analisis, tes, serta pengecekan API. Gunakan checkout cloud yang sudah ada;
tidak perlu membuat Git worktree. Modul lama tersedia untuk diedit, tetapi
validasi onboarding difokuskan pada aplikasi UTS.

Pengujian web internal dari build yang sudah ada:

```sh
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/web
```

Untuk pengembangan interaktif, gunakan `flutter run -d web-server` atau perangkat
Android lokal. Proses server perlu dijalankan ulang pada task cloud baru.

Domain tambahan cloud: `storage.googleapis.com` (artefak Flutter),
`dummyjson.com` (API), dan `cdn.dummyjson.com` (gambar). Domain paket, GitHub,
Gradle, Maven, dan Android SDK memakai preset package managers.

Jika Flutter melaporkan SDK constraint tidak cocok, gunakan versi toolchain
di atas. Jika muncul error lain, sertakan teks error lengkap, hasil
`flutter --version`, dan perintah yang dijalankan agar penyebabnya bisa diperiksa.

## Hasil validasi cloud

- `flutter analyze`: tidak ada temuan.
- `flutter test`: 22 tes lulus (11 tes API dan 11 tes widget).
- API asli mengembalikan 194 produk saat diperiksa; jumlah dapat berubah.
- Build web dan APK debug ARM64 berhasil.
- Tes Chromium dengan API asli: katalog, pencarian dengan input keyboard, dan
  detail produk berhasil; tidak ada error JavaScript.
- Skrip setup berhasil dijalankan; instalasi ulang dengan lockfile tetap sama.
- Manifest APK memuat izin internet, target API 36, dan minimum API 24.

APK belum diuji dengan dipasang pada ponsel fisik atau emulator Android.

## Kesesuaian ketentuan UTS

| Ketentuan PDF | Implementasi |
| --- | --- |
| Flutter dan Dart, GUI minimal satu halaman | `UtsStoreApp` dan `StorePage`, dengan katalog, favorit, dan keranjang |
| Memeriksa struktur API sebelum menentukan fitur | [Contoh respons API](docs/contoh_respons_api.json), atribut produk dipetakan ke `Product` |
| Request HTTP dan pemeriksaan status | `ProductService.fetchProducts()`, HTTPS, status 200 dan timeout 20 detik |
| Konversi JSON ke objek Dart | `Product.fromJson()` di `lib/models/product.dart` |
| Asynchronous dengan FutureBuilder | Future disimpan di `initState`; `FutureBuilder<List<Product>>` menangani snapshot waiting/data/error |
| Loading, success, error | Spinner, katalog produk, pesan error dan tombol Coba lagi |
| Struktur rapi dan README | Halaman, model, service, widget, test, dan dokumentasi terpisah |
| Pengujian sistematis | 22 tes otomatis, API asli, build web/APK dan screenshot aplikasi |
| Source code di repo public | Folder `UTS` di repo `4zzaa/MobilePrak`; tautan pengumpulan: https://github.com/4zzaa/MobilePrak/tree/master/UTS |
| Laporan PDF berstruktur | Draf laporan dan sumber Markdown tersedia di `docs`; identitas dan logo fakultas harus dilengkapi |

Future hanya diganti ketika pengguna melakukan refresh/retry. Mengetik pencarian
atau berpindah tab tidak melakukan request berulang. Jika refresh gagal, data
terakhir dipertahankan dan kegagalan diberitahukan melalui pesan.

Sebelum pengumpulan, lengkapi cover laporan, periksa isi PDF, unggah PDF ke Google
Drive, lalu atur akses **Anyone with the link / Viewer** dan uji tanpa login.
Tautan GitHub dan tautan Google Drive perlu dikumpulkan sesuai instruksi dosen.
Tenggat pada PDF: **23 Oktober 2026, pukul 23.59 WIB**.

Tool dokumentasi opsional menggunakan Python, Playwright, dan ReportLab; ketiganya
tidak diperlukan untuk menjalankan aplikasi Flutter. `capture_screenshots.py`
memakai API asli untuk alur normal dan mensimulasikan request lambat/gagal hanya
untuk menunjukkan tampilan loading dan error. Screenshot merupakan hasil web
pada viewport ponsel, bukan tangkapan layar perangkat Android fisik.

## Berkas laporan

- [Draf laporan PDF](docs/Laporan_UTS_MONO_Store_DRAF.pdf): 16 halaman dengan cover, BAB I–III, daftar pustaka, dan tujuh screenshot bernomor.
- [Sumber laporan yang dapat diedit](docs/LAPORAN_UTS.md).
- [Log hasil pengujian](docs/hasil_pengujian.txt).
- [Template identitas cover](docs/identitas.contoh.json).

Cover belum berisi identitas mahasiswa dan logo fakultas karena datanya belum
diberikan. Jangan mengumpulkan PDF draf sebagai laporan final. Untuk membuat
ulang PDF di lingkungan cloud/Linux, isi `docs/identitas.json` mengikuti template,
letakkan logo fakultas resmi di dalam `docs`, lalu jalankan:

```sh
python3 tool/build_report.py
```

Gunakan path relatif terhadap `docs` untuk field `logo_fakultas`. Jika semua
identitas dan logo tersedia, generator menghasilkan `Laporan_UTS_MONO_Store.pdf`.
