import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class OCRService {
  final textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<String> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<Map<String, String>> extractBusinessCard(File imageFile) async {
    final text = await extractTextFromImage(imageFile);

    // Simple parsing for business card - in real app, use more sophisticated regex or ML
    final lines = text.split('\n');
    String name = '';
    String company = '';
    String phone = '';
    String email = '';
    String website = '';

    for (final line in lines) {
      if (line.contains('@') && email.isEmpty) {
        email = line.trim();
      } else if (RegExp(r'\+?[\d\-\(\) ]{7,}').hasMatch(line) &&
          phone.isEmpty) {
        phone = line.trim();
      } else if (RegExp(r'www\.|\.com|\.org|\.net|http').hasMatch(line) &&
          website.isEmpty) {
        website = line.trim();
      } else if (name.isEmpty) {
        name = line.trim(); // Assume first line is name
      } else if (company.isEmpty) {
        company = line.trim(); // Assume second line is company
      }
    }

    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
    };
  }

  void dispose() {
    textRecognizer.close();
  }
}
