import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';  // Temporarily disabled
import 'dart:io';
import '../cubit/auth_cubit.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/di/injection_container.dart';

class ProfileForm extends StatefulWidget {
  final User user;
  final VoidCallback? onProfileUpdated;

  const ProfileForm({
    super.key,
    required this.user,
    this.onProfileUpdated,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedImagePath;
  bool _isImageLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = widget.user.displayName ?? '';
    _emailController.text = widget.user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   // Image picker functionality temporarily disabled due to compatibility issues
  //   // try {
  //   //   final ImagePicker picker = ImagePicker();
  //   //   final XFile? image = await picker.pickImage(
  //   //     source: ImageSource.gallery,
  //   //     maxWidth: 512,
  //   //     maxHeight: 512,
  //   //     imageQuality: 85,
  //   //   );
  //   //   
  //   //   if (image != null) {
  //   //     setState(() {
  //   //       _selectedImagePath = image.path;
  //   //     });
  //   //   }
  //   // } catch (e) {
  //   //   if (mounted) {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(content: Text('Lỗi chọn ảnh: $e')),
  //   //     );
  //   //   }
  //   // }
  // }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String? imageUrl;
      
      // Upload image if selected
      if (_selectedImagePath != null) {
        setState(() {
          _isImageLoading = true;
        });
        
        try {
          final imageUploadService = sl<ImageUploadService>();
          imageUrl = await imageUploadService.uploadProfileImage(File(_selectedImagePath!));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tải ảnh: $e')),
            );
          }
          return;
        } finally {
          if (mounted) {
            setState(() {
              _isImageLoading = false;
            });
          }
        }
      }

      // Update user profile - using the existing updateProfile method
      if (mounted) {
        context.read<AuthCubit>().updateProfile(
          displayName: _nameController.text.trim(),
          photoURL: imageUrl ?? widget.user.photoURL,
        );
        
        widget.onProfileUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật hồ sơ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Profile Image Section
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImagePath != null
                      ? FileImage(File(_selectedImagePath!))
                      : (widget.user.photoURL != null
                          ? NetworkImage(widget.user.photoURL!)
                          : null) as ImageProvider?,
                  child: _selectedImagePath == null && widget.user.photoURL == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Temporarily disabled image picker functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image picker functionality temporarily disabled'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
                if (_isImageLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Form Fields
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: false, // Email không được chỉnh sửa
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang lưu...'),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text('Lưu thay đổi'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 