# BirdCount Mobile

BirdCount Mobile is a Flutter application for detecting and counting birds in images using a YOLOv8 model served by a FastAPI backend. Users can capture a photo, choose an image from the gallery, send it to the API, and review the detection result with bounding boxes, object count, confidence scores, and local history.

## Features

- Capture images with the device camera.
- Select existing images from the gallery.
- Configure detection confidence threshold.
- Upload images to a FastAPI backend using multipart form data.
- Run YOLOv8 inference with `backend/models/best.pt`.
- Display detection result image with bounding boxes.
- Show bird count, average confidence, and per-object confidence.
- Save detection history locally on the device.
- Check API health status from the mobile app.
- Configure API base URL with `.env` or `--dart-define`.

## Tech Stack

| Layer | Technology |
| --- | --- |
| Mobile | Flutter, Dart, Material 3 |
| Local storage | SharedPreferences, path_provider |
| Image input | image_picker |
| HTTP client | http |
| Backend | Python, FastAPI, Uvicorn |
| Detection | Ultralytics YOLOv8, OpenCV |

## Project Structure

```text
birdcount/
|-- backend/
|   |-- main.py
|   |-- detector.py
|   |-- requirements.txt
|   |-- models/
|   |   `-- best.pt
|   |-- uploads/
|   `-- results/
|-- lib/
|   |-- config/
|   |-- models/
|   |-- screens/
|   |-- services/
|   |-- widgets/
|   `-- main.dart
|-- test/
|-- .env.example
|-- pubspec.yaml
`-- README.md
```

## Requirements

### Mobile

- Flutter SDK
- Android Studio or Android SDK
- Android emulator or physical Android device

### Backend

- Python 3.10 or newer
- YOLOv8 model file: `backend/models/best.pt`

## Environment Configuration

Create a local `.env` file from the example:

```bash
copy .env.example .env
```

Set the API base URL:

```env
API_BASE_URL=http://10.0.2.2:8000
```

Common values:

| Target | API_BASE_URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8000` |
| Web or desktop | `http://localhost:8000` |
| Physical Android device | `http://<your-computer-ip>:8000` |

You can also override the value at runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Priority order:

1. `--dart-define=API_BASE_URL=...`
2. `.env`
3. Built-in fallback URL

## Backend Setup

Install dependencies and start the API:

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Place the YOLO model at:

```text
backend/models/best.pt
```

Health check:

```bash
curl http://localhost:8000/api/health
```

Expected response:

```json
{
  "status": "ok",
  "model": "best.pt",
  "model_loaded": true
}
```

## Mobile Setup

Install Flutter dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Build Android APK:

```bash
flutter build apk --release
```

## API Reference

### GET `/api/health`

Checks API and model availability.

Response:

```json
{
  "status": "ok",
  "model": "best.pt",
  "model_loaded": true
}
```

### POST `/api/detect`

Runs detection on an uploaded image.

Request type:

```text
multipart/form-data
```

Fields:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `image` | file | Yes | Image to detect |
| `confidence` | float | No | Confidence threshold, default `0.5` |

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
    }
  ],
  "result_image": "/results/result.jpg",
  "message": null
}
```

## Testing

Run static analysis:

```bash
flutter analyze
```

Run widget tests:

```bash
flutter test
```

Check backend syntax:

```bash
python -m py_compile backend/main.py backend/detector.py
```

## Notes

- `.env` is intentionally ignored by Git. Commit `.env.example` only.
- `backend/models/*.pt` is ignored to avoid committing large model files.
- Uploaded images and generated result images are stored under `backend/uploads/` and `backend/results/`.
- For physical Android devices, ensure the phone and backend server are on the same network.

## License

This project is prepared for BirdCount Mobile development and deployment. Add the final license file if the repository will be distributed publicly.
