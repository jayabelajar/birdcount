# BirdCount Backend

FastAPI service for YOLOv8 bird detection.

## Setup

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Put your trained model here:

```text
backend/models/best.pt
```

## Run

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## API

```http
GET /api/health
POST /api/detect
```

`POST /api/detect` expects `multipart/form-data`:

- `image`: image file
- `confidence`: threshold, default `0.5`
