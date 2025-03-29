import 'package:biz_hub/models/user.dart';
import 'package:biz_hub/services/auth_service.dart';
import 'package:biz_hub/services/storage_service.dart';
import 'package:biz_hub/services/user_service.dart';
import 'package:biz_hub/utils/validators.dart';
import 'package:biz_hub/widgets/form_section.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserEditScreen extends StatefulWidget {
  final User user;

  const UserEditScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;

  File? _profileImage;
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: ''); // Bio not in new model
    _locationController =
        TextEditingController(text: ''); // Location not in new model
    _phoneController =
        TextEditingController(text: ''); // Phone not in new model
    _websiteController =
        TextEditingController(text: ''); // Website not in new model
    _imageUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl = _imageUrl;

        // Upload new image if selected
        if (_profileImage != null) {
          final path = 'users/${widget.user.id}/profile.jpg';
          imageUrl = await _storageService.uploadFile(_profileImage!, path);
        }

        // Update user data with new model
        final updatedUser = User(
          id: widget.user.id,
          name: _nameController.text,
          email: widget.user.email,
          photoUrl: imageUrl ?? '',
          reputation: widget.user.reputation,
          contributions: widget.user.contributions,
          savedCompanies: widget.user.savedCompanies,
          savedResumes: widget.user.savedResumes,
          createdAt: widget.user.createdAt,
        );

        await _userService.updateUserProfile(
            widget.user.id, updatedUser as Map<String, dynamic>);

        // Update display name in auth if changed
        // if (widget.user.name != _nameController.text) {
        //   await _authService.updateUserProfile(_nameController.text);
        // }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, updatedUser);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!) as ImageProvider
                                : (_imageUrl != null && _imageUrl!.isNotEmpty
                                    ? NetworkImage(_imageUrl!) as ImageProvider
                                    : AssetImage(
                                            'assets/images/default_avatar.png')
                                        as ImageProvider),
                          ),
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Personal Information Section
                    FormSection(
                      title: 'Personal Information',
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: Validators.validateName,
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Account Information (Read-only)
                    FormSection(
                      title: 'Account Information',
                      children: [
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text('Email'),
                          subtitle: Text(widget.user.email),
                        ),
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Reputation'),
                          subtitle: Text(widget.user.reputation.toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Contributions'),
                          subtitle:
                              Text(widget.user.contributions.length.toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.bookmark),
                          title: Text('Saved Companies'),
                          subtitle: Text(
                              widget.user.savedCompanies.length.toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.description),
                          title: Text('Saved Resumes'),
                          subtitle:
                              Text(widget.user.savedResumes.length.toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text('Joined'),
                          subtitle: Text(widget.user.createdAt
                              .toLocal()
                              .toString()
                              .split(' ')[0]),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
