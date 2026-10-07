import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'result_screen.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key, required this.image});

  final File image;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final _apiService = ApiService();
  double _confidence = .5;
  bool _detecting = false;
  String? _error;

  Future<void> _detect() async {
    setState(() {
      _detecting = true;
      _error = null;
    });

    try {
      final result = await _apiService.detect(
        image: widget.image,
        confidence: _confidence,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(image: widget.image, result: result),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _detecting = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(widget.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Confidence Threshold',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${_confidence.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF65747A)),
            ),
            Slider(
              value: _confidence,
              min: .25,
              max: .95,
              divisions: 70,
              label: _confidence.toStringAsFixed(2),
              onChanged: _detecting
                  ? null
                  : (value) => setState(() => _confidence = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD2D2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFE05252),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFF8F3030)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _detecting ? null : _detect,
                icon: _detecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_detecting ? 'Detecting...' : 'Detect Birds'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
