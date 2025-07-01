import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  Future<void> initialize() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller?.initialize();
    }
  }

  Future<String?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile image = await controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'goal_evidence_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = path.join(directory.path, fileName);
      await image.saveTo(savedPath);
      return savedPath;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'goal_evidence_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String savedPath = path.join(directory.path, fileName);
        await image.saveTo(savedPath);
        return savedPath;
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
