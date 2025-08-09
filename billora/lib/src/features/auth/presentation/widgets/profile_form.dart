import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../cubit/auth_cubit.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/di/injection_container.dart';

class ProfileForm extends StatefulWidget {
  final User user;
  final VoidCallback? onClose;

  const ProfileForm({
    super.key,
    required this.user,
    this.onClose,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm>
    with TickerProviderStateMixin {
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isImageLoading = false;
  
  // Animation controllers
  late AnimationController _formController;
  late AnimationController _imageController;
  late AnimationController _buttonController;
  
  // Animations
  late Animation<double> _formAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.user.displayName ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    // Email không được chỉnh sửa - sẽ được xử lý trong TextField
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));
    
    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _formController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _imageController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _formController.dispose();
    _imageController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isImageLoading = true;
    });
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // Remove size restrictions to accept all image files
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get dependencies before async operations
      final authCubit = context.read<AuthCubit>();
      
      // Implement image upload to Firebase Storage
      String? photoURL;
      if (_selectedImage != null) {
        // Get ImageUploadService from dependency injection
        final imageUploadService = sl<ImageUploadService>();
        photoURL = await imageUploadService.uploadProfileImage(_selectedImage!);
      }
      
      await authCubit.updateProfile(
        displayName: _displayNameController.text.trim(),
        photoURL: photoURL,
      );
      
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClose?.call();
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_formAnimation.value * 0.2),
          child: Opacity(
            opacity: _formAnimation.value,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Update your information',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar section
                          AnimatedBuilder(
                            animation: _imageAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _imageAnimation.value,
                                child: _buildAvatarSection(),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Form fields
                          _buildFormFields(),
                          
                          const SizedBox(height: 32),
                          
                          // Action buttons
                          AnimatedBuilder(
                            animation: _buttonAnimation,
                            builder: (context, child) {
                              final clampedOpacity = _buttonAnimation.value.clamp(0.0, 1.0);
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - _buttonAnimation.value)),
                                child: Opacity(
                                  opacity: clampedOpacity,
                                  child: _buildActionButtons(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Avatar container
        GestureDetector(
          onTap: _isImageLoading ? null : _pickImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipOval(
                        child: kIsWeb
                            ? Image.memory(
                                Uint8List.fromList(_selectedImage!.readAsBytesSync()),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _selectedImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      )
                    : widget.user.photoURL != null && widget.user.photoURL!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              widget.user.photoURL!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            ),
                          )
                        : _buildDefaultAvatar(),
              ),
              
              // Camera icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isImageLoading
                      ? const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF667eea),
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Tap to change photo',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    if (widget.user.displayName != null && widget.user.displayName!.isNotEmpty) {
      return Center(
        child: Text(
          widget.user.displayName![0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const Icon(
        Icons.person,
        color: Colors.white,
        size: 48,
      );
    }
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Display Name Field
        _buildTextField(
          controller: _displayNameController,
          label: 'Display Name',
          icon: Icons.person_outline,
          hint: 'Enter your display name',
        ),
        
        const SizedBox(height: 20),
        
        // Email Field (Read-only)
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          hint: 'Your email address',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? Colors.grey[300]! : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? Colors.black87 : Colors.grey[600],
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF667eea) : Colors.grey[500],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: enabled ? const Color(0xFF667eea) : Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : widget.onClose,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Save button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
} 