import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_practice/screens/profile/services/profile_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  String? _profileImageUrl;
  String? _provider;
  String? _userId;
  DateTime? _createdAt;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = _profileService.getUserProfile();

      setState(() {
        _emailController.text = profile['email'] ?? '';
        _nameController.text = profile['full_name'] ?? '';
        _profileImageUrl = profile['avatar_url'];
        _userId = profile['id'];
        _createdAt = profile['created_at'];

        final providerName = profile['provider'] as String;
        _provider = providerName == 'google' ? 'Google' : 'Email';

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load profile: $e', isError: true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUploadingImage = true;
        });

        // Upload image
        final oldImageUrl = _profileImageUrl;
        final newImageUrl = await _profileService.uploadProfilePicture(
          _selectedImage!,
        );

        // Delete old image if it exists and isn't from Google
        if (oldImageUrl != null && !oldImageUrl.contains('googleusercontent')) {
          await _profileService.deleteOldProfilePicture(oldImageUrl);
        }

        setState(() {
          _profileImageUrl = newImageUrl;
          _isUploadingImage = false;
        });

        _showSnackBar('Profile picture updated successfully!');
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      _showSnackBar('Failed to upload image: $e', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFF7DF27),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFF7DF27)),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Name cannot be empty', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _profileService.updateProfile(
        fullName: _nameController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        _showSnackBar('Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Failed to update profile: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFF7DF27),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFF7DF27)),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7DF27)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFF1A1A1A),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (_profileImageUrl != null
                                            ? NetworkImage(_profileImageUrl!)
                                            : null)
                                        as ImageProvider?,
                              child:
                                  _profileImageUrl == null &&
                                      _selectedImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Color(0xFFF7DF27),
                                    )
                                  : null,
                            ),
                            if (_isUploadingImage)
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFF7DF27),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7DF27),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Tap to change profile picture',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  const SizedBox(height: 32),

                  // Provider Badge
                  if (_provider != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF7DF27).withAlpha(77),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _provider == 'Google'
                                ? Icons.g_mobiledata
                                : Icons.email,
                            color: const Color(0xFFF7DF27),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Signed in with $_provider',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    enabled: _isEditing,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFFF7DF27),
                      ),
                      filled: true,
                      fillColor: _isEditing
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF0A0A0A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFF7DF27),
                          width: 2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Field (Read-only)
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    style: const TextStyle(color: Colors.white70),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFF7DF27),
                      ),
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Email cannot be changed',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save/Cancel Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    setState(() {
                                      _isEditing = false;
                                      _loadUserProfile();
                                    });
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7DF27),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Account Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'User ID',
                          _userId?.substring(0, 8) ?? 'N/A',
                        ),
                        const Divider(color: Colors.grey, height: 24),
                        _buildInfoRow(
                          'Account Created',
                          _formatDate(_createdAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
