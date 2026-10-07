class BoundingBox {
  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num?)?.toDouble() ?? 0,
      y1: (json['y1'] as num?)?.toDouble() ?? 0,
      x2: (json['x2'] as num?)?.toDouble() ?? 0,
      y2: (json['y2'] as num?)?.toDouble() ?? 0,
    );
  }

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  Map<String, dynamic> toJson() => {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};
}

class BirdDetection {
  const BirdDetection({
    required this.label,
    required this.confidence,
    required this.bbox,
  });

  factory BirdDetection.fromJson(Map<String, dynamic> json) {
    return BirdDetection(
      label: (json['class'] ?? json['label'] ?? 'burung').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      bbox: BoundingBox.fromJson(
        Map<String, dynamic>.from(json['bbox'] as Map? ?? const {}),
      ),
    );
  }

  final String label;
  final double confidence;
  final BoundingBox bbox;

  Map<String, dynamic> toJson() => {
    'class': label,
    'confidence': confidence,
    'bbox': bbox.toJson(),
  };
}

class DetectionResult {
  const DetectionResult({
    required this.success,
    required this.count,
    required this.averageConfidence,
    required this.detections,
    this.resultImage,
    this.message,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final items = (json['detections'] as List? ?? const [])
        .map((item) => BirdDetection.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return DetectionResult(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? items.length,
      averageConfidence: (json['average_confidence'] as num?)?.toDouble() ?? 0,
      detections: items,
      resultImage: json['result_image']?.toString(),
      message: json['message']?.toString(),
    );
  }

  final bool success;
  final int count;
  final double averageConfidence;
  final List<BirdDetection> detections;
  final String? resultImage;
  final String? message;

  Map<String, dynamic> toJson() => {
    'success': success,
    'count': count,
    'average_confidence': averageConfidence,
    'detections': detections.map((item) => item.toJson()).toList(),
    'result_image': resultImage,
    'message': message,
  };
}
