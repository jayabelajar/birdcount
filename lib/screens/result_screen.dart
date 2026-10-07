import 'dart:io';

import 'package:flutter/material.dart';

import '../models/detection_result.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/detection_card.dart';
import '../widgets/result_image.dart';
import 'detection_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
    this.historyMode = false,
  });

  final File image;
  final DetectionResult result;
  final bool historyMode;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _apiService = ApiService();
  final _historyService = HistoryService();
  bool _saving = false;
  bool _saved = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await _historyService.saveResult(
      sourceImage: widget.image,
      result: widget.result,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _saved = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Detection saved to history')));
  }

  @override
  Widget build(BuildContext context) {
    final resultImageUrl = _apiService.resolveImageUrl(
      widget.result.resultImage,
    );
    final noBirds = widget.result.count == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            ResultImage(
              localImagePath: widget.image.path,
              networkImageUrl: resultImageUrl,
            ),
            const SizedBox(height: 20),
            if (noBirds)
              _NoBirds(message: widget.result.message)
            else
              _Summary(result: widget.result),
            const SizedBox(height: 20),
            Text(
              'Detection Details',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (widget.result.detections.isEmpty)
              Text(
                'Tidak ada deteksi untuk ditampilkan.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: const Color(0xFF65747A)),
              )
            else
              ...widget.result.detections.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DetectionCard(
                    index: entry.key + 1,
                    detection: entry.value,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            if (!widget.historyMode)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving || _saved ? null : _save,
                  icon: Icon(
                    _saved ? Icons.check_rounded : Icons.save_alt_rounded,
                  ),
                  label: Text(
                    _saved ? 'Saved' : (_saving ? 'Saving...' : 'Save Result'),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => DetectionScreen(image: widget.image),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Detect Again'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => Navigator.of(context).popUntil((route) {
                return route.isFirst;
              }),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3EAED)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detected',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF65747A)),
                ),
                const SizedBox(height: 6),
                Text(
                  '${result.count} Birds',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                Text(
                  'Average Confidence',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF65747A)),
                ),
              ],
            ),
          ),
          ConfidenceIndicator(value: result.averageConfidence),
        ],
      ),
    );
  }
}

class _NoBirds extends StatelessWidget {
  const _NoBirds({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF6E2A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.search_off_rounded, color: Color(0xFF9A6A00)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Birds Detected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6F4E00),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message ?? 'Tidak ditemukan burung pada gambar. Coba gunakan gambar lain atau turunkan confidence threshold.',
                  style: const TextStyle(color: Color(0xFF6F4E00)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
