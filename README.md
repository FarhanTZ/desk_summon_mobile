# Desk Summon Mobile 📱⚡

Desk Summon Mobile adalah aplikasi remote kontrol berbasis Flutter yang memungkinkan kamu memilih target belajar/kerja dari HP (misal: IELTS, Coding, Google Docs, Video Course), dan secara otomatis memicu laptop di meja kerja untuk membuka workspace terkait (VS Code, browser, dsb) secara realtime via Supabase.

## ✨ Fitur Utama
- **Todo & Task List Workspace**: Daftar target harian dengan one-tap `Summon` ke laptop.
- **Multi-Workspace Presets**:
  - 📖 **IELTS Prep**: Membuka materi belajar IELTS di browser.
  - 💻 **Coding**: Membuka workspace project di VS Code.
  - 📄 **Google Docs / Notes**: Membuka Google Docs / sheet kerja.
  - 📺 **Video Course / Lofi**: Membuka playlist YouTube / kuliah online.
  - 🔗 **Custom Link**: Menambahkan URL & project path kustom secara dinamis.
- **Realtime Status Laptop**: Mendengarkan status aktivitas workspace laptop secara instan via Supabase Realtime Stream.
- **Give Up / Selesai Sesi**: Tombol darurat untuk menyelesaikan sesi fokus tanpa rasa bersalah.

## 🛠️ Prasyarat
- Flutter SDK (3.x+)
- Supabase Project URL & Anon Key

## 🚀 Cara Menjalankan

1. **Clone repository:**
   ```bash
   git clone https://github.com/FarhanTZ/desk_summon_mobile.git
   cd desk_summon_mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi:**
   ```bash
   # Di Chrome / Edge
   flutter run -d edge

   # Di HP Android (Pastikan USB Debugging aktif)
   flutter run -d <DEVICE_ID>
   ```
