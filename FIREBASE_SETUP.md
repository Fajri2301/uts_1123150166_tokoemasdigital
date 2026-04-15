# STEP 2: SETUP FIREBASE

## Panduan Setup Firebase Console

### 1. Buat Firebase Project
1. Buka https://console.firebase.google.com/
2. Klik "Add Project"
3. Masukkan nama project: "toko-emas-digital"
4. Disable Google Analytics (untuk menghindari biaya)
5. Klik "Create Project"

### 2. Setup Firebase Authentication
1. Di Firebase Console, klik "Authentication"
2. Klik "Get Started"
3. Enable "Email/Password"
4. Klik "Save"

### 3. Setup Firestore Database
1. Di Firebase Console, klik "Firestore Database"
2. Klik "Create Database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih lokasi server: "asia-southeast2" (Jakarta)
5. Klik "Enable"

### 4. Tambahkan Aplikasi Android
1. Di Firebase Console, klik "Project Settings"
2. Scroll ke bawah, klik icon Android
3. Masukkan package name: `com.tokoemas.toko_emas_digital`
4. Download file `google-services.json`
5. Letakkan di: `android/app/google-services.json`

### 5. Tambahkan Aplikasi Web
1. Di Firebase Console, klik icon Web (</>)
2. Masukkan nama app: "Toko Emas Web"
3. Copy Firebase config
4. Update file `lib/core/constants/firebase_config.dart`

### 6. Firestore Security Rules (Test Mode)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 7, 1);
    }
  }
}
```

### 7. Buat Collection di Firestore
Buat collection berikut:
- `users` - untuk data user
- `products` - untuk produk emas fisik
- `transactions` - untuk riwayat transaksi
- `gold_prices` - untuk harga emas terkini
