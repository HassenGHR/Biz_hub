import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/services/storage_service.dart';
import 'package:biz_hub/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/company.dart';

class CompanyFormScreen extends StatefulWidget {
  final Company? company;
  final bool isEditing;

  const CompanyFormScreen({Key? key, this.company})
      : isEditing = company != null,
        super(key: key);

  @override
  _CompanyFormScreenState createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
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

  List<String> _categories = [];

  void _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoriesSet = await _companyService.getCategories();
      setState(() {
        _categories = categoriesSet.toSet().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading categories: ${e.toString()}');
    }
  }

  String limitTitleLength(String? title, {int maxLength = 35}) {
    if (title == null || title.isEmpty) return '';

    return title.length > maxLength
        ? '${title.substring(0, maxLength)}...'
        : title;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _nameController = TextEditingController(text: widget.company?.name ?? "");
    _addressController =
        TextEditingController(text: widget.company?.address ?? "");
    _phoneController = TextEditingController(text: widget.company?.phone ?? "");
    _emailController = TextEditingController(text: widget.company?.email ?? '');
    _websiteController =
        TextEditingController(text: widget.company?.website ?? '');
    _descriptionController =
        TextEditingController(text: widget.company?.description ?? '');
    _selectedCategory = widget.company?.category ?? "";

    // For new company, don't consider initial state as edited
    _isEdited = widget.isEditing ? false : true;

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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    final bottomSheetResult = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Company Image",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: "Camera",
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: "Gallery",
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    if (bottomSheetResult != null) {
      final XFile? pickedFile = await _picker.pickImage(
        source: bottomSheetResult,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isEdited = true;
        });
      }
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Upload new image if selected
      if (_imageFile != null) {
        // For editing, use existing ID, for new company create a temporary ID
        final String fileId = widget.isEditing
            ? widget.company!.id
            : DateTime.now().millisecondsSinceEpoch.toString();

        imageUrl = await _storageService.uploadFile(_imageFile!, fileId);
      } else if (widget.isEditing) {
        // Keep existing image if no new one was selected
        imageUrl = widget.company?.imageUrl;
      }

      final DateTime now = DateTime.now();

      if (widget.isEditing) {
        // Update existing company
        final updatedCompany = Company(
          id: widget.company!.id,
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
          imageUrl: imageUrl ?? "",
          ratings: widget.company!.ratings,
          updatedAt: now,
          location: widget.company!.location,
          thumbsUp: widget.company!.thumbsUp,
          thumbsDown: widget.company!.thumbsDown,
          createdAt: widget.company!.createdAt,
          createdBy: widget.company!.createdBy,
          lastUpdatedBy: widget.company!.lastUpdatedBy,
        );

        await _companyService.editCompany(widget.company!.id, updatedCompany);
        _showSuccessSnackBar('Company updated successfully');
      } else {
        // Create new company
        final newCompany = Company(
          id: '', // This will be assigned by the service
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
          imageUrl: imageUrl ?? "",
          ratings: 0.0,
          updatedAt: now,
          createdAt: now,
          thumbsUp: 0,
          thumbsDown: 0,
          // These fields might need to be set depending on your app's auth system
          createdBy: "System",
          lastUpdatedBy:
              widget.company == null ? "System" : widget.company!.lastUpdatedBy,
          location: null,
        );

        await _companyService.addCompany(newCompany);
        _showSuccessSnackBar('Company added successfully');
      }

      setState(() {
        _isLoading = false;
        _isEdited = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
          'Error ${widget.isEditing ? "updating" : "adding"} company: ${e.toString()}');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
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
          title: Text(widget.isEditing ? 'Edit Company' : 'Add Company'),
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: _isEdited && !_isLoading ? _saveCompany : null,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section with company image
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade200,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          image: _imageFile != null
                                              ? DecorationImage(
                                                  image: FileImage(_imageFile!),
                                                  fit: BoxFit.cover,
                                                )
                                              : widget.isEditing &&
                                                      widget.company!
                                                              .imageUrl !=
                                                          null &&
                                                      widget.company!.imageUrl!
                                                          .isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(widget
                                                          .company!.imageUrl!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                        ),
                                        child: (_imageFile == null &&
                                                (!widget.isEditing ||
                                                    widget.company!.imageUrl ==
                                                        null ||
                                                    widget.company!.imageUrl!
                                                        .isEmpty))
                                            ? Icon(
                                                Icons.business,
                                                size: 60,
                                                color: Colors.grey.shade400,
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Company Logo',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form Section Title - Basic Info
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),

                          // Company Name
                          _buildTextField(
                            controller: _nameController,
                            label: 'Company Name',
                            icon: Icons.business,
                            isRequired: true,
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: 16),

                          // Category Dropdown
                          _buildDropdownField(),
                          const SizedBox(height: 24),

                          // Form Section Title - Contact Details
                          _buildSectionTitle('Contact Details'),
                          const SizedBox(height: 16),

                          // Address
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            icon: Icons.location_on,
                            isRequired: true,
                            validator: Validators.validateAddress,
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                            validator: Validators.validatePhone,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.isNotEmpty
                                ? Validators.validateEmail(value)
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Website
                          _buildTextField(
                            controller: _websiteController,
                            label: 'Website',
                            icon: Icons.language,
                            keyboardType: TextInputType.url,
                            validator: (value) => value!.isNotEmpty
                                ? Validators.validateUrl(value)
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Form Section Title - Additional Info
                          _buildSectionTitle('Additional Information'),
                          const SizedBox(height: 16),

                          // Description
                          _buildDescriptionField(),
                          const SizedBox(height: 40),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isEdited && !_isLoading
                                  ? _saveCompany
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      widget.isEditing
                                          ? 'Save Changes'
                                          : 'Add Company',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          color: Colors.grey.shade300,
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      validator: (value) => Validators.validateName(value),
      decoration: InputDecoration(
        labelText: 'Category *',
        prefixIcon: Icon(Icons.category, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(limitTitleLength(category)),
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
      hint: const Text('Select a category'),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Description',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
        hintText: 'Provide a description of your company...',
      ),
    );
  }
}
