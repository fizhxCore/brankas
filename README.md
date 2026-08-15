# Brankas (APK)

Vault pribadi offline — nyimpen link, catatan, secret, code, dan dokumen.
Semua data tersimpan lokal di HP (file JSON), tanpa server, tanpa internet.

## Build APK (via GitHub Actions, bukan lokal)

1. Extract zip ini, push semua isinya ke repo GitHub baru.
2. Buka tab **Actions** di repo, workflow "Build APK" akan otomatis jalan
   tiap push ke branch `main` (atau jalankan manual lewat "Run workflow").
3. Setelah selesai (~5-10 menit), buka run yang sukses → bagian
   **Artifacts** → download `brankas-apk`. Isinya `app-release.apk`.
4. Transfer APK ke HP, install (aktifkan "Install dari sumber tidak
   dikenal" kalau diminta).

Workflow-nya generate folder `android/` dari nol setiap build (bukan
disimpan di repo), jadi repo tetap ringan — cuma `lib/` dan `pubspec.yaml`.

## Cara pakai

- **Buka pertama kali**: diminta bikin ID + password sendiri (tersimpan
  aman di device pakai secure storage, bukan di file JSON biasa).
- **Login berikutnya**: masuk pakai ID + password yang sama.
- **Tambah item**: tombol + di kanan bawah, pilih kategori (Note, Secret,
  Link, Code, Document), isi judul (opsional) dan konten.
- **Cari**: search bar di atas, filter tambahan per kategori di bawahnya.
- **Secret**: konten disembunyikan (••••) secara default di list maupun
  detail, ada tombol tampilkan/sembunyikan.
- **Export ke TXT**: menu titik tiga di kanan atas → hasil pencarian/filter
  yang lagi tampil diekspor jadi satu file `.txt`, dibagikan lewat share
  sheet (simpan, kirim ke WA, dll).
- **Backup & Restore**: menu titik tiga → export seluruh data sebagai file
  `.json` (buat disimpan di Drive dsb). Buat restore: buka file `.json` itu
  pakai app Files/text editor apa aja, copy isinya, tempel di kolom yang
  disediakan, lalu tekan restore. Restore akan **menimpa** data yang ada
  saat ini.

## Soal keamanan

- ID dan password login disimpan terenkripsi lewat `flutter_secure_storage`
  (Android Keystore).
- Isi entry (termasuk kategori Secret) disimpan **tidak terenkripsi** di
  file JSON internal aplikasi — amannya mengandalkan sandbox penyimpanan
  aplikasi Android (app lain nggak bisa akses tanpa root). Kalau butuh
  lapisan enkripsi tambahan untuk isi Secret, itu bisa ditambahkan
  belakangan — kabari aja kalau mau.

## Struktur data

Satu file `brankas_data.json` di folder dokumen aplikasi, isinya array
entry: `{ id, category, title, content, createdAt }`.
