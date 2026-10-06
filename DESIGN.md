# Design System Guidelines — Desk Summon Mobile 🎨

## 1. Philosophy & Aesthetic
- **Light Minimalist with Electric/Royal Blue Accents**: Kanvas putih bersih (`#F8FAFC` & `#FFFFFF`) dipadukan dengan tipografi judul hitam pekat yang tegas (`#0F172A`), serta warna aksen **Electric / Royal Blue (`#2563EB`)** untuk tombol aksi utama dan highlight.
- **Horizontal Task Carousel & Vertical Full View Architecture**:
  - **Home Screen**: Menampilkan *Horizontal Scrollable Cards* (Card persegi panjang ke samping) untuk task hari ini (*Today Task*).
  - **See All Page**: Menampilkan halaman daftar penuh vertikal (*Full Vertical List*) lengkap dengan search & tab filter lengkap ketika tombol **See All** ditekan.
- **Concentric Circular Icon Filter Cards (Traffic Light Palette)**: 
  - 🔴 **To Do**: Red Theme (`#EF4444` / `#FEF2F2`)
  - 🟡 **In Progress**: Amber/Yellow Theme (`#F59E0B` / `#FFFBEB`)
  - 🟢 **Done**: Emerald/Green Theme (`#10B981` / `#ECFDF5`)

---

## 2. Color Palette Tokens

| Token Name | Hex Code | Deskripsi & Penggunaan |
| :--- | :--- | :--- |
| **Canvas / Background** | `#F8FAFC` (Slate 50) | Warna dasar halaman aplikasi |
| **Card / Surface** | `#FFFFFF` (Pure White) | Kartu modul, kontainer list, drawer, modal |
| **Border / Stroke** | `#E2E8F0` (Slate 200) | Garis batas tipis pada kartu & search bar |
| **Title Text** | `#0F172A` (Solid Black) | Judul utama, App Bar, headline utama |
| **Primary Blue Accent** | `#2563EB` (Bright Royal Blue) | Tombol Summon, FAB, highlight "$totalThisMonth tasks" |
| **To Do Status** | `#EF4444` / `#FEF2F2` (Red) | Filter Lingkaran Todo |
| **In Progress Status** | `#F59E0B` / `#FFFBEB` (Amber) | Filter Lingkaran In Progress |
| **Done Status** | `#10B981` / `#ECFDF5` (Emerald) | Filter Lingkaran Done |
| **Body / Description** | `#1E293B` (Deep Black) | Teks nama task, input search, isi form |
| **Text Muted** | `#64748B` (Slate 500) | Subtitle ucapan, placeholder search, label filter |
