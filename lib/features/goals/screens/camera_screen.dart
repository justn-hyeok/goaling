import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraScreen({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 촬영'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraService.controller!),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'gallery',
                  onPressed: () async {
                    final imagePath =
                        await _cameraService.pickImageFromGallery();
                    if (imagePath != null && mounted) {
                      widget.onImageCaptured(imagePath);
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.photo_library),
                ),
                FloatingActionButton(
                  heroTag: 'camera',
                  onPressed: () async {
                    final imagePath = await _cameraService.takePicture();
                    if (imagePath != null && mounted) {
                      widget.onImageCaptured(imagePath);
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
