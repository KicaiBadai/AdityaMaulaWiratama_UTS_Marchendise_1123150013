# 🛒 Pasar Malam - UTS Mobile Application Lanjutan

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](#)
[![Go](https://img.shields.io/badge/go-%2300ADD8.svg?style=for-the-badge&logo=go&logoColor=white)](#)

Aplikasi E-Commerce modern yang dibangun dengan **Flutter** sebagai frontend, **Firebase** untuk autentikasi, serta **Golang** & **MySQL** sebagai backend API. Proyek ini merupakan bagian dari Ujian Tengah Semester mata kuliah Aplikasi Lanjutan.

---

## 👨‍💻 Identitas Pengembang

| Detail Profil | Informasi |
| :--- | :--- |
| **Nama** | Aditya Maula Wiratama |
| **NIM** | 1123150013 |
| **Kelas** | TI SE 23 P1 |
| **Program Studi** | Teknik Informatika (Software Engineering) |
| **Video Demo** | [📺 Tonton di YouTube](https://youtu.be/B-fyerymbI4) |

---

## 🚀 Fitur Utama

- **Authentication**: Login & Register menggunakan Firebase (Email & Google Sign-In).
- **Theme Management**: Mendukung Mode Terang (Light) dan Mode Gelap (Dark) secara real-time.
- **Product Management**: Menampilkan list produk dari database melalui backend Golang.
- **Search & Filter**: Pencarian produk berdasarkan nama dan filter kategori dinamis.
- **State Management**: Menggunakan `Provider` untuk manajemen state yang efisien.

---

## 🛠️ Tech Stack

| Komponen | Teknologi | Deskripsi |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Antarmuka pengguna dan logika client-side. |
| **Auth** | Firebase Auth | Verifikasi email dan login Google pihak ketiga. |
| **Backend** | Golang (Gin/Echo) | RESTful API penengah antara App dan Database. |
| **Database** | MySQL | Penyimpanan data produk dan relasi data lokal. |

---

## 📸 Dokumentasi Antarmuka (UI)

### 🔐 Autentikasi
| Awal | Google Login | Register |
| :---: | :---: | :---: |
| ![Login Awal](https://github.com/user-attachments/assets/9bb0bc05-eb0a-4c88-800c-8f53e23233a4) | ![Login Google](https://github.com/user-attachments/assets/d5437b0d-5ab7-4385-a59c-8990c77d42c0) | ![Register](https://github.com/user-attachments/assets/9ebab38f-dc06-450f-94dd-b5fd9ac5f656) |

### 🏠 Dashboard & Fitur
| List Produk | Filter Kategori | Pencarian |
| :---: | :---: | :---: |
| ![Dashboard](https://github.com/user-attachments/assets/200b3e34-3e8f-4ff8-ae26-6a592db62899) | ![Filter](https://github.com/user-attachments/assets/d2f03607-ff88-46b1-8aa2-04809071e457) | ![Search](https://github.com/user-attachments/assets/d7c1e6d6-be8e-40a8-b307-bca3596fb71e) |

### 🌗 Perbandingan Mode Tema
| Light Mode | Dark Mode |
| :---: | :---: |
| ![Light](https://github.com/user-attachments/assets/6da37aae-6309-40ba-b3c0-a74e57c3c33d) | ![Dark](https://github.com/user-attachments/assets/e46f6457-64ee-4ab8-a397-6c6e08260d29) |

---

## 🏗️ Cara Menjalankan Proyek

### 1. Prasyarat
- Flutter SDK terinstall.
- Go (Golang) terinstall.
- Database MySQL aktif.

### 2. Konfigurasi Backend
1. Masuk ke direktori backend.
2. Jalankan migrasi database MySQL.
3. Run project: `go run main.go`.

### 3. Konfigurasi Frontend
1. Clone repository ini.
2. Jalankan `flutter pub get`.
3. Pastikan `google-services.json` (Firebase) sudah terkonfigurasi di direktori android.
4. Jalankan aplikasi: `flutter run`.

---
