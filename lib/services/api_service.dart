import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/detection_result.dart';

class ApiHealth {
  const ApiHealth({
    required this.online,
    this.status,
    this.model,
    this.message,
  });

  final bool online;
  final String? status;
  final String? model;
  final String? message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<ApiHealth> checkHealth() async {
    try {
      final response = await _client
          .get(_uri('/api/health'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ApiHealth(online: false, message: 'HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiHealth(
        online: true,
        status: data['status']?.toString(),
        model: data['model']?.toString(),
      );
    } catch (error) {
      return ApiHealth(online: false, message: error.toString());
    }
  }

  Future<DetectionResult> detect({
    required File image,
    required double confidence,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/detect'))
      ..fields['confidence'] = confidence.toStringAsFixed(2)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded['detail']?.toString() ??
            decoded['message']?.toString() ??
            'Detection failed',
      );
    }

    return DetectionResult.fromJson(decoded);
  }

  String resolveImageUrl(String? resultImage) {
    if (resultImage == null || resultImage.isEmpty) {
      return '';
    }
    final uri = Uri.tryParse(resultImage);
    if (uri != null && uri.hasScheme) {
      return resultImage;
    }
    return '${ApiConfig.baseUrl}$resultImage';
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
