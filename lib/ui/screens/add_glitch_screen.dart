import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/glitch_model.dart';
import '../../services/database_helper.dart';
import '../../services/camera_service.dart';
import '../../services/notification_service.dart';
import '../../services/imgbb_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'image_painter_screen.dart';

class AddGlitchScreen extends StatefulWidget {
  final Glitch? glitch; // Null for Add, non-null for Edit

  const AddGlitchScreen({Key? key, this.glitch}) : super(key: key);

  @override
  State<AddGlitchScreen> createState() => _AddGlitchScreenState();
}

class _AddGlitchScreenState extends State<AddGlitchScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  String? _imagePath;
  bool _isSaving = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.glitch?.title ?? '');
    _descController = TextEditingController(text: widget.glitch?.description ?? '');
    _imagePath = widget.glitch?.imagePath;

    // Only fetch location if it's a new glitch
    if (widget.glitch == null) {
      _fetchLocation();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street}, ${place.subLocality}, ${place.locality}';
        
        if (mounted) {
          setState(() {
            _descController.text = 'Location: $address\nCoordinates: ${position.latitude}, ${position.longitude}\n\nNotes: ';
          });
        }
      }
    } catch (e) {
      print('Location error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _takePhoto() async {
    final path = await CameraService().takePhoto();
    if (path != null) {
      if (mounted) {
        // Open fullscreen painter
        final finalPath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePainterScreen(imagePath: path),
          ),
        );
        
        if (finalPath != null) {
          setState(() {
            _imagePath = finalPath;
          });
        }
      }
    }
  }

  void _saveGlitch() async {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please take a photo of the glitch!')),
        );
        return;
      }

      setState(() => _isSaving = true);

      String onlineImageUrl = _imagePath!;
      
      // If imagePath doesn't start with 'http', it means a new local photo was taken, so we must upload it.
      if (!onlineImageUrl.startsWith('http')) {
        try {
          // Upload to ImgBB
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading image to Cloud...')),
          );
          onlineImageUrl = await ImgbbService.uploadImage(_imagePath!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
            setState(() => _isSaving = false);
          }
          return; // Abort saving if upload fails
        }
      }

      final glitchToSave = Glitch(
        id: widget.glitch?.id, // Keep the old ID if editing
        title: _titleController.text,
        description: _descController.text,
        imagePath: onlineImageUrl, // Save online URL instead of local path
        dateCaught: widget.glitch?.dateCaught ?? DateTime.now().toIso8601String().split('T')[0], // Keep old date if editing
      );

      if (widget.glitch == null) {
        final id = await DatabaseHelper.instance.insert(glitchToSave);
        // Trigger Local Notification
        await NotificationService().showNotification(
          id: id,
          title: 'New Glitch Caught!',
          body: '${glitchToSave.title} was successfully saved to your Dex.',
        );
      } else {
        await DatabaseHelper.instance.update(glitchToSave);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, true); // Return true to signal success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catch a Glitch'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: _imagePath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 60, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text('Tap to open Camera', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Glitch Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description / Location',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  suffixIcon: _isLoadingLocation 
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) 
                      : null,
                ),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveGlitch,
                icon: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save to Dex', style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
