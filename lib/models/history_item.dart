import 'detection_result.dart';

class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    required this.result,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'].toString(),
      imagePath: json['image_path'].toString(),
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      result: DetectionResult.fromJson(
        Map<String, dynamic>.from(json['result'] as Map? ?? const {}),
      ),
    );
  }

  final String id;
  final String imagePath;
  final DateTime createdAt;
  final DetectionResult result;

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_path': imagePath,
    'created_at': createdAt.toIso8601String(),
    'result': result.toJson(),
  };
}
