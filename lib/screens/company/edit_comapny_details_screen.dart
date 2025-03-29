import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/services/storage_service.dart';
import 'package:biz_hub/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/company.dart';

class EditCompanyScreen extends StatefulWidget {
  final Company company;

  const EditCompanyScreen({Key? key, required this.company}) : super(key: key);

  @override
  _EditCompanyScreenState createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final CompanyService _companyService = CompanyService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;

  String _selectedCategory = '';
  File? _imageFile;
  bool _isLoading = false;
  bool _isEdited = false;

  final List<String> _categories = [
    'Technology',
    'Retail',
    'Healthcare',
    'Food',
    'Services',
    'Education',
    'Finance',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.name);
    _addressController = TextEditingController(text: widget.company.address);
    _phoneController = TextEditingController(text: widget.company.phone);
    _emailController = TextEditingController(text: widget.company.email ?? '');
    _websiteController =
        TextEditingController(text: widget.company.website ?? '');
    _descriptionController =
        TextEditingController(text: widget.company.description ?? '');
    _selectedCategory = widget.company.category;

    // Add listeners to track changes
    _nameController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _websiteController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _isEdited = true;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isEdited = true;
      });
    }
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = widget.company.imageUrl;

      // Upload new image if selected
      if (_imageFile != null) {
        imageUrl =
            await _storageService.uploadFile(_imageFile!, widget.company.id);
      }

      // Create updated company object
      final updatedCompany = Company(
        id: widget.company.id,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        website:
            _websiteController.text.isEmpty ? null : _websiteController.text,
        category: _selectedCategory,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        imageUrl: imageUrl,
        ratings: widget.company.ratings,
        updatedAt: DateTime.now(),
        location: widget.company.location,
        thumbsUp: widget.company.thumbsUp,
        thumbsDown: widget.company.thumbsDown,
        createdAt: widget.company.createdAt,
        createdBy: widget.company.createdBy,
        lastUpdatedBy: widget.company.lastUpdatedBy,
      );

      // Update company in database
      await _companyService.editCompany(widget.company.id, updatedCompany);

      setState(() {
        _isLoading = false;
        _isEdited = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating company: ${e.toString()}')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isEdited) return true;

    // Show confirmation dialog if changes were made
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Company'),
          actions: [
            TextButton(
              onPressed: _isEdited && !_isLoading ? _saveCompany : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _isEdited && !_isLoading
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Logo/Image
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (widget.company.imageUrl != null
                                        ? NetworkImage(widget.company.imageUrl!)
                                        : null) as ImageProvider?,
                                child: widget.company.imageUrl == null &&
                                        _imageFile == null
                                    ? const Icon(Icons.business, size: 60)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Company Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateName(
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                              _isEdited = true;
                            });
                          }
                        },
                        validator: (value) => Validators.validateName(
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateAddress(
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => Validators.validatePhone(value),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isNotEmpty
                            ? Validators.validateEmail(value)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Website
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.language),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) => value!.isNotEmpty
                            ? Validators.validateUrl(value)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isEdited && !_isLoading ? _saveCompany : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
