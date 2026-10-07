import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection_result.dart';
import '../models/history_item.dart';

class HistoryService {
  static const _storageKey = 'birdcount_history';

  Future<List<HistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => HistoryItem.fromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<HistoryItem> saveResult({
    required File sourceImage,
    required DetectionResult result,
  }) async {
    final history = await loadHistory();
    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory(path.join(directory.path, 'birdcount'));
    await imagesDirectory.create(recursive: true);

    final createdAt = DateTime.now();
    final extension = path.extension(sourceImage.path).isEmpty
        ? '.jpg'
        : path.extension(sourceImage.path);
    final id = createdAt.microsecondsSinceEpoch.toString();
    final storedPath = path.join(imagesDirectory.path, '$id$extension');
    await sourceImage.copy(storedPath);

    final item = HistoryItem(
      id: id,
      imagePath: storedPath,
      createdAt: createdAt,
      result: result,
    );
    history.insert(0, item);
    await _persist(history);
    return item;
  }

  Future<void> deleteItem(String id) async {
    final history = await loadHistory();
    final item = history.where((entry) => entry.id == id).firstOrNull;
    if (item != null) {
      final file = File(item.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    history.removeWhere((entry) => entry.id == id);
    await _persist(history);
  }

  Future<void> clearHistory() async {
    final history = await loadHistory();
    for (final item in history) {
      final file = File(item.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persist(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(history.map((item) => item.toJson()).toList()),
    );
  }
}
