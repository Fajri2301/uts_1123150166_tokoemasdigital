# Panduan Setup Supabase Storage

## 1. Buat Project Supabase
1. Buka https://supabase.com/
2. Login dengan GitHub
3. Klik "New Project"
4. Isi:
   - Organization: Pilih atau buat baru
   - Project name: toko-emas-digital
   - Database Password: buat password kuat
   - Region: Southeast Asia (Singapore)
5. Klik "Create new project"

## 2. Setup Storage Bucket
1. Di Supabase Dashboard, klik "Storage" di sidebar kiri
2. Klik "Create Bucket"
3. Isi:
   - Bucket name: `product-images`
   - Public: **Ya** (centang Public bucket)
4. Klik "Save"

## 3. Konfigurasi RLS (Row Level Security)
Karena bucket public, kita tidak perlu RLS untuk read.
Tapi untuk upload dari app, pastikan anon key punya akses:

```sql
-- Policy untuk allow upload dari client
CREATE POLICY "Allow public upload"
ON storage.objects
FOR INSERT
TO authenticated, anon
WITH CHECK (bucket_id = 'product-images');

-- Policy untuk allow read
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO authenticated, anon
USING (bucket_id = 'product-images');

-- Policy untuk allow delete
CREATE POLICY "Allow public delete"
ON storage.objects
FOR DELETE
TO authenticated, anon
USING (bucket_id = 'product-images');
```

## 4. Dapatkan API Credentials
1. Di Supabase Dashboard, klik "Project Settings" (icon gear)
2. Klik "API" di sidebar
3. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbG...`
4. Paste ke file `lib/core/constants/supabase_config.dart`

## 5. Struktur Folder di Storage
```
product-images/
└── products/
    ├── product_1_timestamp.jpg
    ├── product_2_timestamp.jpg
    └── ...
```

## 6. Flow Upload Gambar
1. Admin pilih gambar dari gallery
2. App upload ke Supabase Storage bucket `product-images`
3. Supabase return public URL
4. Simpan URL ke Firestore di field `image_url`
5. Gambar tampil di app

## 7. Contoh URL Publik
```
https://xxxxx.supabase.co/storage/v1/object/public/product-images/products/nama_file.jpg
```
