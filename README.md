# WebSocket Chat System - UTS Metodologi Penelitian II

Project ini adalah sistem backend chat real-time yang dibangun menggunakan **Golang**, **PostgreSQL**, dan **Redis**. Selain sebagai aplikasi chat, project ini berfungsi sebagai lingkungan pengujian untuk riset perbandingan performa indexing pada database.

## 📂 Struktur Folder & Arsitektur

Project ini mengikuti pola modular untuk memastikan kode mudah dikelola dan dikembangkan:

* **`config/`**: Mengelola konfigurasi global, termasuk pemuatan variabel lingkungan (ENV) dari Docker dan inisialisasi koneksi database (GORM & Redis).
* **`handlers/`**: Lapisan logika aplikasi. Menangani request masuk, proses *upgrade* koneksi ke WebSocket, dan validasi input pengguna.
* **`middleware/`**: Penengah request untuk menangani fungsi seperti Logging, CORS, dan Autentikasi keamanan.
* **`model/`**: Definisi struktur data tunggal. Berisi **Entities** untuk skema tabel PostgreSQL dan **DTO** (Data Transfer Object) untuk pertukaran data JSON dengan Flutter.
* **`repository/`**: Lapisan akses data (Data Access Layer). Fokus pada manipulasi database seperti menyimpan pesan atau mengambil riwayat chat menggunakan GORM.
* **`routers/`**: Definisi jalur API (Endpoint). Mengatur pemetaan URL ke fungsi handler yang sesuai (misal: `/ws` untuk chat).
* **`main.go`**: Titik masuk utama aplikasi yang menginisialisasi server dan menghubungkan semua modul saat dijalankan.

## 🔬 Fokus Riset: Optimasi Database
Project ini mengimplementasikan dua jenis index pada PostgreSQL untuk dibandingkan efisiensinya:
1.  **B-Tree Index**: Digunakan pada kolom `created_at` dan `sender_id` untuk mempercepat pencarian pesan berdasarkan waktu dan pengirim.
2.  **GIN (Generalized Inverted Index)**: Digunakan pada kolom `content` untuk mendukung fitur *Full-Text Search* yang efisien saat mencari kata kunci di dalam ribuan pesan.

## 🚀 Teknologi yang Digunakan
- **Language**: Go (Golang) 1.24+
- **Database**: PostgreSQL 16 (Primary Storage)
- **Cache**: Redis 7 (Real-time Status & Pub/Sub)
- **ORM**: GORM
- **DevOps**: Docker & Docker Compose
- **Environment**: Ubuntu WSL2

## 🛠️ Cara Menjalankan
1. Pastikan Docker Desktop sudah aktif.
2. Jalankan perintah berikut di terminal:
   ```bash
   docker compose up --build