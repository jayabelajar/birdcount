import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({super.key, required this.value, this.size = 88});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0, 1).toDouble();

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: normalized,
            strokeWidth: 8,
            backgroundColor: const Color(0xFFE5EDF0),
            color: const Color(0xFF159A6A),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(normalized * 100).round()}%',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
