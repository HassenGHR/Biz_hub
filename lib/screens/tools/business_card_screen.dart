import 'dart:io';
import 'package:biz_hub/models/company.dart';
import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/services/ocr_service.dart';
import 'package:biz_hub/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BusinessCardScannerScreen extends StatefulWidget {
  const BusinessCardScannerScreen({Key? key}) : super(key: key);

  @override
  _BusinessCardScannerScreenState createState() =>
      _BusinessCardScannerScreenState();
}

class _BusinessCardScannerScreenState extends State<BusinessCardScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final CompanyService _companyService = CompanyService();
  final AuthService _authService = AuthService();

  File? _imageFile;
  bool _isProcessing = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _personNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isProcessing = true;
        });

        await _processBusinessCard();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _processBusinessCard() async {
    try {
      if (_imageFile != null) {
        final Map<String, String> cardInfo =
            await _ocrService.extractBusinessCard(_imageFile!);

        // Update form fields with extracted info
        setState(() {
          _companyNameController.text = cardInfo['company'] ?? '';
          _personNameController.text = cardInfo['name'] ?? '';
          _phoneController.text = cardInfo['phone'] ?? '';
          _emailController.text = cardInfo['email'] ?? '';
          _websiteController.text = cardInfo['website'] ?? '';
          _addressController.text = cardInfo['address'] ?? '';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing business card: $e')),
      );
    }
  }

  Future<void> _saveBusinessCard() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isProcessing = true;
        });

        // Get current user ID
        String userId = _authService.currentUser?.uid ?? 'unknown';

        // Create company object with the new model
        final company = Company(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _companyNameController.text,
          email: _emailController.text,
          description: _descriptionController.text,
          category: _categoryController.text.isEmpty
              ? 'Uncategorized'
              : _categoryController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          website: _websiteController.text,
          imageUrl: '', // This would typically be set after uploading the image
          location: const GeoPoint(0,
              0), // Default location, would be updated with actual coordinates
          thumbsUp: 0,
          thumbsDown: 0,
          ratings: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: userId,
          lastUpdatedBy: userId,
        );

        // Save to database
        await _companyService.addCompany(company);

        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business card saved successfully')),
        );

        // Reset form
        _resetForm();
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving business card: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _imageFile = null;
    _companyNameController.clear();
    _personNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _websiteController.clear();
    _addressController.clear();
    _categoryController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _personNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Card Scanner'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scan business cards and save contact details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.photo_camera,
                      label: 'Take Photo',
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_imageFile != null) ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else if (_companyNameController.text.isNotEmpty ||
                  _personNameController.text.isNotEmpty) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Information',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _personNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailRegExp =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegExp.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveBusinessCard,
                          child: const Text('Save Business Card'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Assuming this custom button is defined elsewhere
class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
