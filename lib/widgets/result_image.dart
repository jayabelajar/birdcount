import 'dart:io';

import 'package:flutter/material.dart';

class ResultImage extends StatelessWidget {
  const ResultImage({
    super.key,
    required this.localImagePath,
    required this.networkImageUrl,
  });

  final String localImagePath;
  final String networkImageUrl;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    Widget fallback() {
      return Image.file(
        File(localImagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final image = networkImageUrl.isEmpty
        ? fallback()
        : Image.network(
            networkImageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => fallback(),
          );

    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF1),
            borderRadius: borderRadius,
          ),
          child: image,
        ),
      ),
    );
  }
}
