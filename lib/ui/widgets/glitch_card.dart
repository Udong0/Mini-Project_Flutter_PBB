import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/glitch_model.dart';
import '../screens/full_screen_image_screen.dart';

class GlitchCard extends StatelessWidget {
  final Glitch glitch;
  final VoidCallback onDelete;

  const GlitchCard({
    Key? key,
    required this.glitch,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 6,
      shadowColor: Colors.greenAccent.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.greenAccent.withOpacity(0.3), width: 1),
      ),
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageScreen(
                    imagePath: glitch.imagePath,
                    heroTag: 'glitch_${glitch.id}',
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Hero(
                tag: 'glitch_${glitch.id}',
                child: glitch.imagePath.startsWith('http')
                    ? Image.network(
                        glitch.imagePath.contains('ibb.co') 
                            ? 'https://wsrv.nl/?url=${glitch.imagePath}&w=800&q=70&output=webp'
                            : glitch.imagePath,
                        headers: const {'User-Agent': 'Mozilla/5.0'},
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[800],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image, color: Colors.greenAccent, size: 50),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Error loading: ${glitch.imagePath}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.black,
                            child: const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
                          );
                        },
                      )
                    : Image.file(
                        File(glitch.imagePath),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[800],
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.greenAccent, size: 50)),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        glitch.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        glitch.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Detected: ${glitch.dateCaught}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: onDelete,
                  tooltip: 'Delete Glitch',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
