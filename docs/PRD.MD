# PRODUCT REQUIREMENTS DOCUMENT (PRD)

## BirdCount Mobile
**Aplikasi Mobile Deteksi dan Penghitungan Burung Menggunakan YOLOv8**

### 1. Deskripsi Project

BirdCount Mobile adalah aplikasi mobile berbasis **Flutter** yang digunakan untuk mendeteksi dan menghitung jumlah burung pada sebuah gambar menggunakan model **YOLOv8**.

Aplikasi mobile terhubung dengan backend Python melalui REST API. Backend menggunakan model `best.pt` dan fungsi deteksi yang berasal dari project `AkasSakti/yoloobj_detect`.

Repository sumber:
`AkasSakti/yoloobj_detect`

---

## 2. Tujuan

Membangun aplikasi mobile yang mampu:

- Mengambil gambar melalui kamera.
- Memilih gambar dari galeri.
- Mengirim gambar ke backend.
- Melakukan object detection menggunakan YOLOv8.
- Menampilkan bounding box objek yang terdeteksi.
- Menghitung jumlah burung.
- Menampilkan confidence hasil deteksi.
- Menyimpan riwayat deteksi secara lokal.

---

## 3. Arsitektur Sistem

```text
Flutter Mobile App
        │
        │ HTTP Multipart
        ▼
FastAPI REST API
        │
        ▼
YOLOv8
models/best.pt
        │
        ▼
detector.py
        │
        ▼
Detection Result
        │
        ├── Bounding Box
        ├── Confidence
        ├── Object Count
        └── Result Image
        │
        ▼
Flutter Mobile App
```

---

## 4. Technology Stack

### Mobile

- Flutter
- Dart
- Dio / HTTP
- Image Picker
- Camera
- SharedPreferences / Hive

### Backend

- Python
- FastAPI
- Uvicorn
- Ultralytics YOLO
- OpenCV
- NumPy
- Pillow

### Machine Learning

- YOLOv8
- Custom model `best.pt`
- Object Detection

---

# 5. Fitur Aplikasi

## 5.1 Home

Halaman utama aplikasi.

Fitur:

- Informasi singkat aplikasi.
- Tombol **Buka Kamera**.
- Tombol **Pilih dari Galeri**.
- Menu riwayat deteksi.
- Status koneksi API.

---

## 5.2 Camera Detection

User dapat mengambil gambar menggunakan kamera smartphone.

Flow:

```text
Buka Kamera
    ↓
Ambil Foto
    ↓
Preview
    ↓
Gunakan Foto
    ↓
Kirim ke API
```

---

## 5.3 Gallery Detection

User dapat memilih gambar yang sudah tersimpan.

Flow:

```text
Pilih Galeri
    ↓
Pilih Gambar
    ↓
Preview
    ↓
Deteksi
    ↓
Kirim ke API
```

---

## 5.4 Detection Process

Setelah gambar dipilih:

1. Flutter membaca gambar.
2. Gambar dikirim menggunakan HTTP multipart.
3. FastAPI menerima gambar.
4. Gambar dikonversi ke format OpenCV.
5. YOLOv8 menjalankan inference.
6. Sistem mengambil bounding box dan confidence.
7. Sistem menghitung jumlah objek.
8. Backend mengembalikan hasil ke Flutter.

---

# 6. Detection Result

Halaman hasil menampilkan:

**Detection Summary**

```text
Jumlah Burung
5

Average Confidence
91.4%
```

**Detection Image**

Menampilkan gambar dengan bounding box pada setiap burung.

**Detection Detail**

```text
Burung #1     95%
Burung #2     93%
Burung #3     91%
Burung #4     90%
Burung #5     88%
```

Tombol:

- Deteksi Ulang
- Simpan Hasil
- Kembali ke Home

---

# 7. Confidence Threshold

User dapat menentukan batas confidence model.

Contoh:

```text
Confidence Threshold

0.25 ─────────●──── 0.95

Current: 0.50
```

Nilai default:

```text
0.50
```

Deteksi di bawah threshold tidak ditampilkan.

---

# 8. History

Aplikasi menyimpan riwayat deteksi secara lokal.

Data:

- Gambar.
- Tanggal.
- Waktu.
- Jumlah burung.
- Average confidence.

Contoh:

```text
07 Oktober 2026
08:20

Detected: 5 birds
Confidence: 91%
```

User dapat:

- Membuka detail.
- Menghapus history.
- Menghapus seluruh history.

---

# 9. REST API

## Health Check

```http
GET /api/health
```

Response:

```json
{
  "status": "ok",
  "model": "best.pt"
}
```

---

## Detect Object

```http
POST /api/detect
```

Request:

```text
multipart/form-data

image: image.jpg
confidence: 0.5
```

Response:

```json
{
  "success": true,
  "count": 3,
  "average_confidence": 0.91,
  "detections": [
    {
      "class": "burung",
      "confidence": 0.94,
      "bbox": {
        "x1": 120,
        "y1": 80,
        "x2": 350,
        "y2": 300
      }
    },
    {
      "class": "burung",
      "confidence": 0.88,
      "bbox": {
        "x1": 400,
        "y1": 100,
        "x2": 580,
        "y2": 320
      }
    }
  ],
  "result_image": "/results/result.jpg"
}
```

---

# 10. Struktur Backend

```text
backend/
│
├── main.py
├── detector.py
│
├── models/
│   └── best.pt
│
├── uploads/
├── results/
│
├── requirements.txt
└── README.md
```

### `main.py`

Bertanggung jawab untuk:

- FastAPI server.
- Endpoint API.
- Upload image.
- Validation.
- Response API.

### `detector.py`

Menggunakan logic dari repository YOLO untuk:

- Load `best.pt`.
- Menjalankan inference.
- Filtering confidence.
- Mengambil bounding box.
- Menghitung objek.
- Membuat gambar hasil deteksi.

---

# 11. Struktur Flutter

```text
mobile/
│
├── lib/
│   ├── main.dart
│   │
│   ├── config/
│   │   └── api_config.dart
│   │
│   ├── models/
│   │   └── detection_result.dart
│   │
│   ├── services/
│   │   ├── api_service.dart
│   │   └── history_service.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── detection_screen.dart
│   │   ├── result_screen.dart
│   │   └── history_screen.dart
│   │
│   └── widgets/
│       ├── detection_card.dart
│       ├── result_image.dart
│       └── confidence_indicator.dart
│
├── assets/
│   ├── images/
│   └── icons/
│
└── pubspec.yaml
```

---

# 12. UI Navigation

```text
Splash
   ↓
Home
 ┌───────┴────────┐
 ↓                ↓
Camera          Gallery
 ↓                ↓
 └───────┬────────┘
         ↓
      Preview
         ↓
      Detection
         ↓
       Result
         ↓
       History
```

Bottom navigation:

```text
Home | History | Settings
```

---

# 13. Screen Design

### Splash Screen

- Logo BirdCount.
- YOLO Detection.
- Loading indicator.

### Home

Header:

```text
BirdCount

AI Bird Detection
```

Main card:

```text
Detect Birds

Take or select a photo to
detect and count birds.

[ Open Camera ]

[ Choose Gallery ]
```

### Detection Result

```text
Detection Result

┌───────────────────────┐
│                       │
│   Bounding Box Image  │
│                       │
└───────────────────────┘

Detected
5 Birds

Average Confidence
91%

Detection Details

Bird #1       95%
Bird #2       93%
Bird #3       91%
Bird #4       89%
Bird #5       87%

[ Detect Again ]
```

---

# 14. Non-Functional Requirements

### Performance

- Model hanya di-load satu kali ketika backend berjalan.
- Response inference ditargetkan beberapa detik per gambar, bergantung perangkat/server.
- Maksimum ukuran upload dapat dibatasi, misalnya 10 MB.

### Compatibility

Mobile:

- Android sebagai target utama.
- Android 8.0 atau lebih baru.

Backend:

- Windows.
- Linux.
- Cloud/VPS.

### Error Handling

Aplikasi harus menangani:

- Backend tidak aktif.
- Tidak ada koneksi.
- Format gambar tidak didukung.
- File terlalu besar.
- Model gagal dijalankan.
- Tidak ada objek yang terdeteksi.

Jika tidak ditemukan objek:

```text
No Birds Detected

Tidak ditemukan burung pada gambar.
Coba gunakan gambar lain atau turunkan
confidence threshold.
```

---

# 15. MVP

Versi pertama cukup memiliki:

1. Flutter mobile application.
2. Kamera.
3. Gallery picker.
4. Preview gambar.
5. FastAPI backend.
6. Integrasi `best.pt`.
7. Deteksi YOLO.
8. Bounding box.
9. Penghitungan burung.
10. Confidence score.
11. Halaman hasil.

History dan settings dapat menjadi fitur tambahan.

---

# 16. Alur Implementasi

```text
Clone YOLO Repository
        ↓
Pastikan best.pt berjalan
        ↓
Pisahkan detector.py
        ↓
Buat FastAPI
        ↓
POST /api/detect
        ↓
Test menggunakan Postman
        ↓
Create Flutter Project
        ↓
Camera + Gallery
        ↓
Integrasi Flutter → FastAPI
        ↓
Tampilkan Detection Result
        ↓
Tambahkan History
        ↓
Testing Android
        ↓
Build APK
```

---

# 17. Output Akhir

Deliverable project:

```text
✓ Source Code Flutter
✓ Source Code FastAPI
✓ YOLOv8 best.pt
✓ REST API
✓ Aplikasi Android APK
✓ Dokumentasi API
✓ README instalasi
✓ Demo deteksi burung
```

Hasil akhirnya adalah aplikasi Android yang memungkinkan pengguna mengambil atau memilih gambar, mengirimkannya ke server YOLOv8, kemudian memperoleh **bounding box, jumlah burung, dan confidence hasil deteksi**.