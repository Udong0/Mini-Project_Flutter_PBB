import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const FullScreenImageScreen({
    Key? key,
    required this.imagePath,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath.contains('ibb.co')
                        ? 'https://wsrv.nl/?url=\$imagePath&w=1200&q=90&output=webp'
                        : imagePath,
                    headers: const {'User-Agent': 'Mozilla/5.0'},
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.greenAccent, size: 100),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                    },
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.greenAccent, size: 100),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
