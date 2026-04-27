import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:path_provider/path_provider.dart';

class ImagePainterScreen extends StatefulWidget {
  final String imagePath;

  const ImagePainterScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ImagePainterScreen> createState() => _ImagePainterScreenState();
}

class _ImagePainterScreenState extends State<ImagePainterScreen> {
  late final ImagePainterController _painterController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _painterController = ImagePainterController();
  }

  void _savePainting() async {
    setState(() => _isExporting = true);
    
    try {
      final paintedImage = await _painterController.exportImage();
      if (paintedImage != null) {
        final tempDir = await getTemporaryDirectory();
        final newPath = '${tempDir.path}/painted_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(newPath);
        await file.writeAsBytes(paintedImage);
        
        if (mounted) {
          Navigator.pop(context, newPath); // Return the new path
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to export image: returned null')));
          Navigator.pop(context, widget.imagePath); // Return original if failed
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context, widget.imagePath); // Return original on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annotate Glitch'),
        backgroundColor: Colors.deepPurple,
        actions: [
          _isExporting
              ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))))
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _savePainting,
                  tooltip: 'Save Annotation',
                )
        ],
      ),
      body: SafeArea(
        child: ImagePainter.file(
          File(widget.imagePath),
          controller: _painterController,
          scalable: false,
        ),
      ),
    );
  }
}
