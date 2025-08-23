// lib/screens/image_preview_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  /// If [isNetwork] is true, [imagePath] is treated as a network URL.
  /// Otherwise it’s treated as a local file path.
  final String imagePath;
  final bool isNetwork;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.isNetwork,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // A transparent AppBar with just an “X” close button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          // Allows pinch-zoom and pan
          minScale: 1.0,
          maxScale: 4.0,
          child:
              isNetwork
                  ? Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        ),
                  )
                  : Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        ),
                  ),
        ),
      ),
    );
  }
}
