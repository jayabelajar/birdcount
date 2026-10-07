import 'package:flutter/material.dart';

import '../models/detection_result.dart';

class DetectionCard extends StatelessWidget {
  const DetectionCard({
    super.key,
    required this.index,
    required this.detection,
  });

  final int index;
  final BirdDetection detection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3EAED)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#$index',
              style: const TextStyle(
                color: Color(0xFF137B58),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detection.label,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${(detection.confidence * 100).round()}%',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
