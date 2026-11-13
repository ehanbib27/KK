# Kamus Kutai — Flutter

Versi Flutter dari prototipe web multi-halaman [ciel-15/ui-kamus-aplikasi](https://github.com/ciel-15/ui-kamus-aplikasi). UI dibangun ulang dengan widget Flutter, sedangkan struktur kosakata dan kategori tetap disimpan sebagai JSON terpisah dari UI.

> Catatan data: dataset 1.623 kosakata ini adalah data awal prototipe, bukan database linguistik yang sudah diverifikasi. Tinjau arti, ejaan, dialek, dan contoh dengan penutur bahasa Kutai sebelum digunakan sebagai referensi resmi.

## Fitur

- Beranda, pencarian kamus, filter kategori dan huruf, detail kata, kategori, favorit, tentang, profil, dan riwayat.
- Kosakata/kategori dibaca dari `assets/data/kosakata_lengkap.json` dan `assets/data/kategori.json`.
- Tema terang/gelap, nama profil, foto profil, favorit, riwayat, dan usulan kosakata disimpan secara lokal di perangkat/browser.
- Foto profil dipilih dari galeri/perangkat, diperkecil, lalu disimpan sebagai data JPEG Base64 di penyimpanan preferensi lokal.
- Layout adaptif memakai Material 3 dan bottom navigation.

## Menyiapkan proyek

Pastikan Flutter SDK terpasang dan `flutter --version` berhasil. Folder ini berisi source Flutter (Dart, `pubspec.yaml`, dan aset). Jika runner platform belum tersedia, buat scaffolding proyek dari terminal di folder ini:

```powershell
flutter create --platforms=android,ios,web,windows .
flutter pub get
```

Jika Flutter menanyakan overwrite file yang sudah ada, jangan izinkan overwrite pada `lib/`, `assets/`, atau `pubspec.yaml`; source proyek ini perlu dipertahankan. Umumnya perintah di atas hanya diperlukan untuk menghasilkan folder runner platform.

### Jalankan di browser

```powershell
flutter run -d chrome
```

### Jalankan di Android

Aktifkan USB debugging atau mulai emulator, lalu:

```powershell
flutter devices
flutter run -d <device_id>
```

### Build APK

```powershell
flutter build apk --release
```

Hasil APK biasanya ada di `build/app/outputs/flutter-apk/app-release.apk`.

## Mengubah database

Edit JSON di `assets/data/`:

- `kosakata_lengkap.json`: `id`, `kata`, `pelafalan`, `kelasKata`, `kategori`, `dialek`, `arti`, `contoh`, `terjemahan`, `catatan`.
- `kategori.json`: `id`, `nama`, `deskripsi`, `ikon`.

Nilai `kategori` setiap kata harus sesuai dengan salah satu `id` di file kategori.

## Penyimpanan lokal dan batasan

Aplikasi belum menggunakan backend/server database. Preferensi menggunakan `shared_preferences`. Data tidak otomatis disinkronkan di perangkat berbeda. Usulan kosakata disimpan lokal dan belum dikirim ke pengelola. Tombol pengucapan masih berupa placeholder; rekaman/TTS bahasa Kutai belum dihubungkan.

Untuk iOS, periksa dokumentasi `image_picker` dan tambahkan permission foto yang diperlukan ke `ios/Runner/Info.plist` jika akan membangun target iOS.

## Pemeriksaan kode

Setelah SDK siap, jalankan:

```powershell
flutter pub get
flutter analyze
flutter test
```
