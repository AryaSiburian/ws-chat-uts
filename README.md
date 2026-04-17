# ws-chat-uts

Aplikasi **real-time chat** berbasis **WebSocket** dengan arsitektur terpisah antara backend dan frontend. Proyek ini saat ini masih dalam tahap **development**, sehingga fitur chat end-to-end dapat terus berkembang seiring iterasi.

## 1) Deskripsi Project

`ws-chat-uts` adalah proyek aplikasi chat yang dirancang untuk komunikasi real-time.

- **Backend (Golang)** menangani API, autentikasi, dan orkestrasi layanan.
- **Frontend (Flutter)** menjadi client mobile untuk interaksi pengguna.
- **PostgreSQL** digunakan sebagai penyimpanan data utama.
- **Redis** disiapkan untuk kebutuhan caching/pub-sub realtime.
- Seluruh service backend dijalankan melalui **Docker Compose**.

> Status saat ini: development (pengembangan aktif).

---

## 2) Tech Stack

- **Golang** (backend API/service)
- **Flutter** (aplikasi mobile)
- **PostgreSQL** (database utama)
- **Redis** (cache & messaging pendukung realtime)
- **Docker & Docker Compose** (container orchestration lokal)

---

## 3) Struktur Folder

Berikut struktur utama project:

```text
ws-chat-uts/
├── backend-go/
├── mobile_flutter/
├── database/
├── docker-compose.yml
├── .env.example
└── README.md
```

### Penjelasan singkat tiap folder

- **`backend-go/`**  
  Berisi source code backend Golang (konfigurasi, handler, middleware, model, routing, dokumentasi Swagger, dan entry point aplikasi).

- **`mobile_flutter/`** *(catatan: ini folder frontend yang ada di repository saat ini)*  
  Berisi source code aplikasi Flutter (UI, state, model, dan konfigurasi multiplatform Android/iOS/Web/Desktop).

- **`database/`**  
  Berisi kebutuhan inisialisasi database (contoh: skrip SQL awal).

- **`docker-compose.yml`**  
  Definisi service container (backend, PostgreSQL, Redis) dan networking antar-service.

- **`.env.example`**  
  Contoh variabel environment minimum untuk koneksi database.

> Jika Anda menggunakan istilah `flutter_mobile`, pada repository ini padanannya adalah folder **`mobile_flutter/`**.

---

## 4) Cara Menjalankan Project

### Prasyarat

Pastikan sudah terpasang:

- Docker + Docker Compose
- Flutter SDK
- Git

### Langkah-langkah

1. **Clone repository**

```bash
git clone <url-repository-anda>
cd ws-chat-uts
```

2. **Siapkan environment file**

```bash
cp .env.example .env
```

Lalu isi nilai variabel pada `.env` sesuai kebutuhan.

3. **Jalankan service backend + database + redis**

```bash
docker compose up --build
```

4. **Pastikan semua service berjalan**

- `chat-backend` (backend)
- `chat-db` (PostgreSQL)
- `chat-redis` (Redis)

Cek status service:

```bash
docker compose ps
```

5. **Jalankan frontend Flutter (terpisah dari Docker Compose)**

Buka terminal baru, lalu:

```bash
cd mobile_flutter
flutter pub get
flutter run
```

---

## 5) Environment

Project menggunakan environment variables untuk konfigurasi koneksi.

### Minimal variabel (berdasarkan `.env.example`)

```env
DB_USER=<username_db>
DB_PASSWORD=<password_db>
DB_NAME=<nama_db>
```

### Variabel yang juga digunakan service backend

```env
DB_HOST=db
DB_PORT=5432
APP_PORT=8080
REDIS_HOST=redis
REDIS_PORT=6379
JWT_SECRET=<secret_token>
```

> `DB_HOST=db` dan `REDIS_HOST=redis` mengikuti nama service pada Docker Compose internal network.

---

## 6) API / WebSocket Info

### API utama (saat ini)

Base path backend:

```text
/api
```

Endpoint yang sudah tersedia antara lain:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/profile/me` (memerlukan JWT)
- `PATCH /api/profile/me` (memerlukan JWT)

Dokumentasi Swagger:

- `GET /swagger/index.html`

### WebSocket

- Endpoint WebSocket umum untuk chat biasanya berada pada path seperti:

```text
/ws
```

- Pada versi saat ini, route WebSocket chat belum diekspos di routing utama backend (masih tahap pengembangan).

Contoh koneksi WebSocket (saat endpoint tersedia):

```text
ws://localhost:8080/ws
```

---

## 7) Catatan Tambahan

- Pastikan Docker daemon aktif sebelum menjalankan `docker compose up --build`.
- Pastikan Flutter SDK siap (`flutter doctor` tidak ada error kritis).
- Jika port bentrok, sesuaikan mapping port pada `docker-compose.yml`.
- Untuk development, jalankan backend via Docker Compose dan frontend secara lokal agar iterasi UI lebih cepat.

---

## Lisensi

Tambahkan informasi lisensi sesuai kebijakan project (mis. MIT, Apache-2.0, atau private internal).
