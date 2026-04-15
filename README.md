# Toko Emas Digital - Flutter App

Aplikasi toko emas digital berbasis Flutter dengan integrasi Firebase, Supabase, dan Live API.

## 📱 Fitur Utama

### 👤 User Features
- ✅ Login & Register (Firebase Auth)
- ✅ Home Screen dengan harga emas live
- ✅ Emas Digital
  - Lihat saldo emas (gram)
  - Beli emas digital
  - Konversi ke emas fisik (batangan)
  - Riwayat transaksi
- ✅ Emas Fisik
  - Katalog produk (cincin, gelang, kalung, anting)
  - Detail produk
  - Checkout dengan alamat pengiriman
- ✅ Tracking Pesanan
  - Status: Diproses → Dikirim → Selesai
  - Vertical stepper UI
- ✅ Portfolio Emas
  - Total gram & nilai rupiah

### 🔧 Admin Panel
- ✅ Dashboard (statistik produk, transaksi, user)
- ✅ CRUD Produk
  - Tambah, edit, hapus produk
  - Upload gambar (Supabase Storage)
- ✅ Update Harga Emas Manual
- ✅ Kelola Transaksi
  - Ubah status transaksi

### 🌐 Live API
- ✅ Auto update harga emas saat app dibuka
- ✅ Fallback ke simulasi jika API gagal
- ✅ Manual refresh

## 🛠️ Teknologi

| Teknologi | Fungsi |
|-----------|--------|
| Flutter (Dart) | Frontend |
| Firebase Auth | Autentikasi user |
| Firebase Firestore | Database |
| Supabase Storage | Storage gambar produk |
| HTTP Client | Live API harga emas |
| Provider | State management |

## 📂 Struktur Folder

```
lib/
├── common/
│   └── widgets/              # Reusable widgets
├── core/
│   ├── constants/            # App constants
│   ├── routes/               # Route definitions
│   ├── services/             # Global services
│   ├── theme/                # App theme
│   └── utils/                # Utility functions
├── features/
│   ├── auth/                 # Authentication
│   ├── admin/                # Admin panel
│   ├── digital_gold/         # Digital gold features
│   ├── home/                 # Home screen
│   ├── physical_gold/        # Physical gold catalog
│   └── tracking/             # Order tracking
└── main.dart
```

## 🚀 Setup & Installasi

### 1. Clone Repository

```bash
git clone https://github.com/Fajri2301/uts_1123150166_tokoemasdigital.git
cd toko_emas_digital
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Firebase

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Email/Password)
3. Buat **Firestore Database** (test mode)
4. Download `google-services.json` untuk Android
   - Letakkan di: `android/app/google-services.json`
5. Tambahkan aplikasi Web di Firebase Console

Lihat panduan lengkap: `FIREBASE_SETUP.md`

### 4. Setup Supabase

1. Buat project di [Supabase](https://supabase.com/)
2. Buat Storage Bucket: `product-images` (public)
3. Copy Project URL & Anon Key
4. Update file: `lib/core/constants/supabase_config.dart`

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String bucketName = 'product-images';
}
```

Lihat panduan lengkap: `SUPABASE_SETUP.md`

### 5. Setup Firestore Collections

Buat collection berikut di Firestore:

**users**
```
- name: string
- email: string
- role: string (user/admin)
- gold_balance: number
- created_at: timestamp
```

**products**
```
- name: string
- category: string (cincin/gelang/kalung/anting)
- price: number
- description: string
- image_url: string
```

**transactions**
```
- user_id: string
- type: string (digital/fisik)
- gold_amount: number
- product_id: string (optional)
- status: string (pending/diproses/dikirim/selesai)
- address: string (optional)
- total_price: number (optional)
- created_at: timestamp
```

**gold_prices**
```
- price_per_gram: number
- updated_at: timestamp
- source: string (api/simulated)
```

### 6. Jalankan Aplikasi

```bash
# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 🎨 UI Design

### Warna
- Background: `#0D0D0D` (hitam)
- Card: Putih opacity 5-10%
- Accent: `#FFD700` (emas)

### Spacing
- Padding: 16px
- Spacing: 12-16px
- Border radius:
  - Search bar: 40px
  - Card: 20px
  - Button: 12px

### Dimensions
- AppBar: 56px
- Search bar: 50px
- Card utama: 150px
- Button: 48px
- Input: 50px
- Product image: 200px

### Grid
- 2 kolom
- Aspect ratio: 3:4

## 📱 User Flow

```
Splash Screen (2 detik)
    ↓
Cek Login
    ↓
├─ Belum login → Login Screen
│       ↓
│   Register Screen
│       ↓
└─ Sudah login → Home Screen
        ↓
    ┌─────────────┬──────────────┐
    ↓             ↓              ↓
Emas Digital  Emas Fisik    Tracking
    ↓             ↓              ↓
┌───┴──────┐  ┌──┴─────┐    Detail
│Beli      │  │Catalog │    Order
│Konversi  │  │Detail  │
│History   │  │Checkout│
└──────────┘  └────────┘
```

## 🔐 Role System

- **User**: Bisa beli emas, lihat katalog, tracking
- **Admin**: Bisa CRUD produk, update harga, kelola transaksi

Untuk set user sebagai admin, update field `role` di Firestore:
```
users/{userId} → role: "admin"
```

## 📸 Upload Gambar

Flow:
1. Admin pilih gambar dari kamera/galeri
2. Upload ke Supabase Storage (`product-images/products/`)
3. Dapatkan public URL
4. Simpan URL ke Firestore (`image_url`)

## 🌐 Gold Price API

Aplikasi menggunakan sistem 3-tier:
1. **Live API** - Fetch dari API harga emas Indonesia
2. **Fallback API** - API alternatif jika utama gagal
3. **Simulasi** - Harga simulasi ±Rp 1.100.000/gram

Auto update:
- Saat app pertama kali dibuka
- Saat user pull-to-refresh
- Manual dari admin panel

## 📝 Git Commit Convention

Format: `fajri : pesan`

Contoh:
```bash
git commit -m "fajri : tambah fitur login"
git commit -m "fajri : fix bug pada checkout"
git commit -m "fajri : update UI home screen"
```

## 👥 Developer

**Fajri Khaerullah**
- NIM: 1123150166
- GitHub: [@Fajri2301](https://github.com/Fajri2301)

## 📄 License

MIT License - UTS Mobile Programming
