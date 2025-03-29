import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(File file, String storagePath) async {
    try {
      // Compress the image if it's a photo
      File compressedFile = await _compressImage(file);

      // Upload to Firebase
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Compress an image file to reduce storage usage and bandwidth
  Future<File> _compressImage(File file) async {
    try {
      // Read the image
      final fileExtension = path.extension(file.path).toLowerCase();
      final image = fileExtension == '.png'
          ? img.decodePng(file.readAsBytesSync())
          : img.decodeJpg(file.readAsBytesSync());

      if (image == null) {
        return file; // Return original if decoding fails
      }

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${path.basename(file.path)}';

      // Resize image if it's too large (max dimension of 1200px)
      img.Image resizedImage = image;
      if (image.width > 1200 || image.height > 1200) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 1200 : null,
          height: image.height >= image.width ? 1200 : null,
        );
      }

      // Encode and save the image with reduced quality
      final compressedData = img.encodeJpg(resizedImage, quality: 85);
      final compressedFile = File(targetPath)..writeAsBytesSync(compressedData);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  // Get a list of files from a directory in storage
  Future<List<String>> getFilesFromDirectory(String directoryPath) async {
    try {
      final ListResult result = await _storage.ref(directoryPath).listAll();
      final List<String> fileUrls = [];

      for (var item in result.items) {
        final String url = await item.getDownloadURL();
        fileUrls.add(url);
      }

      return fileUrls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
