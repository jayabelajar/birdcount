from pathlib import Path
from typing import Annotated
from uuid import uuid4

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from detector import BirdDetector, DetectorError

BASE_DIR = Path(__file__).resolve().parent
UPLOAD_DIR = BASE_DIR / "uploads"
RESULT_DIR = BASE_DIR / "results"
MODEL_PATH = BASE_DIR / "models" / "best.pt"
MAX_UPLOAD_BYTES = 10 * 1024 * 1024

UPLOAD_DIR.mkdir(exist_ok=True)
RESULT_DIR.mkdir(exist_ok=True)

app = FastAPI(title="BirdCount API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.mount("/results", StaticFiles(directory=RESULT_DIR), name="results")

detector = BirdDetector(model_path=MODEL_PATH, result_dir=RESULT_DIR)


@app.get("/api/health")
def health_check() -> dict[str, str | bool]:
    return {
        "status": "ok",
        "model": MODEL_PATH.name,
        "model_loaded": detector.is_ready,
    }


@app.post("/api/detect")
async def detect_object(
    image: Annotated[UploadFile, File()],
    confidence: Annotated[float, Form()] = 0.5,
) -> dict:
    if confidence < 0.0 or confidence > 1.0:
        raise HTTPException(status_code=422, detail="Confidence must be 0.0 - 1.0")

    if image.content_type and not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Unsupported image format")

    payload = await image.read()
    if len(payload) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail="Image must be 10 MB or smaller")

    suffix = Path(image.filename or "upload.jpg").suffix or ".jpg"
    upload_path = UPLOAD_DIR / f"{uuid4().hex}{suffix}"
    upload_path.write_bytes(payload)

    try:
        result = detector.detect(upload_path=upload_path, confidence=confidence)
    except DetectorError as error:
        raise HTTPException(status_code=503, detail=str(error)) from error
    except Exception as error:
        raise HTTPException(status_code=500, detail=f"Detection failed: {error}") from error

    return result
