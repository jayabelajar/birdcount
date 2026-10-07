from pathlib import Path
from uuid import uuid4

import cv2


class DetectorError(RuntimeError):
    pass


class BirdDetector:
    def __init__(self, model_path: Path, result_dir: Path) -> None:
        self.model_path = model_path
        self.result_dir = result_dir
        self._model = None

    @property
    def is_ready(self) -> bool:
        return self.model_path.exists()

    def _load_model(self):
        if self._model is not None:
            return self._model

        if not self.model_path.exists():
            raise DetectorError(
                f"Model not found at {self.model_path}. Put best.pt in backend/models/."
            )

        try:
            from ultralytics import YOLO
        except ImportError as error:
            raise DetectorError(
                "ultralytics is not installed. Run: pip install -r requirements.txt"
            ) from error

        self._model = YOLO(str(self.model_path))
        return self._model

    def detect(self, upload_path: Path, confidence: float) -> dict:
        model = self._load_model()
        image = cv2.imread(str(upload_path))
        if image is None:
            raise DetectorError("Uploaded file cannot be decoded as an image")

        results = model.predict(source=str(upload_path), conf=confidence, verbose=False)
        detections = []

        for result in results:
            names = result.names
            for box in result.boxes:
                score = float(box.conf[0])
                class_id = int(box.cls[0])
                x1, y1, x2, y2 = [float(value) for value in box.xyxy[0]]
                label = names.get(class_id, "burung") if isinstance(names, dict) else "burung"

                detections.append(
                    {
                        "class": label,
                        "confidence": score,
                        "bbox": {
                            "x1": round(x1, 2),
                            "y1": round(y1, 2),
                            "x2": round(x2, 2),
                            "y2": round(y2, 2),
                        },
                    }
                )

                cv2.rectangle(
                    image,
                    (int(x1), int(y1)),
                    (int(x2), int(y2)),
                    (21, 154, 106),
                    3,
                )
                cv2.putText(
                    image,
                    f"{label} {score:.0%}",
                    (int(x1), max(24, int(y1) - 8)),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (21, 154, 106),
                    2,
                    cv2.LINE_AA,
                )

        count = len(detections)
        average_confidence = (
            sum(item["confidence"] for item in detections) / count if count else 0.0
        )
        result_name = f"result_{uuid4().hex}.jpg"
        result_path = self.result_dir / result_name
        cv2.imwrite(str(result_path), image)

        return {
            "success": True,
            "count": count,
            "average_confidence": round(average_confidence, 4),
            "detections": detections,
            "result_image": f"/results/{result_name}",
            "message": None
            if count
            else "Tidak ditemukan burung pada gambar. Coba gambar lain atau turunkan confidence threshold.",
        }
