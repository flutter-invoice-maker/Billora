import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/core/services/vip_threshold_service.dart';
import 'package:billora/src/features/customer/presentation/widgets/vip_threshold_settings.dart';
import 'package:billora/src/core/utils/currency_formatter.dart';
import 'package:billora/src/core/services/image_upload_service.dart';
import 'package:billora/src/core/services/avatar_service.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;

class CustomerFormPage extends StatefulWidget {
  final Customer? customer;
  final Map<String, String>? prefill;
  final bool forceCreate;
  const CustomerFormPage({super.key, this.customer, this.prefill, this.forceCreate = false});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late bool _isVip;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // VIP related variables
  final VipThresholdService _vipService = VipThresholdService();
  double _customerRevenue = 0.0;
  double _vipThreshold = 1000.0;
  bool _isLoadingVipData = false;

  // Avatar related variables
  String? _selectedImagePath;
  String? _currentAvatarUrl;
  bool _isUploadingAvatar = false;
  late final ImageUploadService _imageUploadService;
  final ImagePicker _imagePicker = ImagePicker();

  // Focus nodes for better UX
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString() + 
      math.Random().nextInt(10000).toString();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? widget.prefill?['name'] ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? widget.prefill?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? widget.prefill?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? widget.prefill?['address'] ?? '');
    _isVip = widget.customer?.isVip ?? (widget.prefill?['isVip'] as bool?) ?? false;
    
    // Initialize avatar
    _currentAvatarUrl = widget.customer?.avatarUrl;
    _imageUploadService = sl<ImageUploadService>();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController.forward();
    _slideController.forward();
    
    // Load VIP data if editing existing customer
    if (widget.customer != null) {
      _loadVipData();
    }
  }

  Future<void> _loadVipData() async {
    if (widget.customer == null) return;
    
    setState(() {
      _isLoadingVipData = true;
    });

    try {
      final revenue = await _vipService.getCustomerTotalRevenue(widget.customer!.id);
      final threshold = await _vipService.getVipThreshold();
      
      setState(() {
        _customerRevenue = revenue;
        _vipThreshold = threshold;
      });
    } catch (e) {
      debugPrint('Error loading VIP data: $e');
    } finally {
      setState(() {
        _isLoadingVipData = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final isCreate = widget.forceCreate || widget.customer == null;
      final customer = Customer(
        id: isCreate ? generateId() : (widget.customer!.id),
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        isVip: _isVip,
        avatarUrl: _currentAvatarUrl,
      );

      if (isCreate) {
        context.read<CustomerCubit>().addCustomer(customer);
        // Update VIP status after customer is created with longer delay
        Future.delayed(const Duration(milliseconds: 2000), () {
          _vipService.updateCustomerVipStatus(customer.id);
        });
      } else {
        context.read<CustomerCubit>().updateCustomer(customer);
        // Update VIP status after customer is updated with longer delay
        Future.delayed(const Duration(milliseconds: 2000), () {
          _vipService.updateCustomerVipStatus(customer.id);
        });
      }

      Navigator.of(context).pop(customer);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _selectedImagePath = imageFile.path;
      _isUploadingAvatar = true;
    });
    
    try {
      // Upload image and get URL
      final customerId = widget.customer?.id ?? generateId();
      final avatarUrl = await _imageUploadService.uploadCustomerAvatar(imageFile, customerId);
      
      if (mounted) {
        setState(() {
          _currentAvatarUrl = avatarUrl;
          _isUploadingAvatar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Select Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1976D2)),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture a new photo with camera'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1976D2)),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select an existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _removeAvatar() async {
    setState(() {
      _selectedImagePath = null;
      _currentAvatarUrl = null;
    });
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AvatarService.getAvatarColor(_nameController.text.isNotEmpty ? _nameController.text : 'Customer'),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1976D2),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          AvatarService.getInitials(_nameController.text.isNotEmpty ? _nameController.text : 'Customer'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1976D2),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Edit Profile' : 'New Contact',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              isEdit ? 'Update' : 'Save',
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1976D2),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _selectedImagePath != null
                                    ? Image.file(
                                        File(_selectedImagePath!),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : _currentAvatarUrl != null
                                        ? Image.network(
                                            _currentAvatarUrl!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return _buildDefaultAvatar();
                                            },
                                          )
                                        : _buildDefaultAvatar(),
                              ),
                            ),
                            // Camera icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploadingAvatar ? null : _showImageSourceDialog,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isUploadingAvatar
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _isUploadingAvatar ? null : _showImageSourceDialog,
                          child: Text(
                            _isUploadingAvatar ? 'Uploading...' : 'Change Photo',
                            style: TextStyle(
                              color: _isUploadingAvatar ? Colors.grey : const Color(0xFF1976D2),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_currentAvatarUrl != null || _selectedImagePath != null)
                          const SizedBox(height: 8),
                        if (_currentAvatarUrl != null || _selectedImagePath != null)
                          GestureDetector(
                            onTap: _removeAvatar,
                            child: const Text(
                              'Remove Photo',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form Fields
                  _buildMinimalTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    label: 'Name',
                    validator: (value) => value == null || value.isEmpty 
                        ? 'Name is required' 
                        : null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMinimalTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value != null && 
                        value.isNotEmpty && 
                        !value.contains('@') 
                        ? 'Invalid email address' 
                        : null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMinimalTextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_addressFocus),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMinimalTextField(
                    controller: _addressController,
                    focusNode: _addressFocus,
                    label: 'Address',
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // VIP Status Display
                  _buildVipStatusDisplay(),
                  
                  const SizedBox(height: 40),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Update Contact' : 'Add Contact',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),
        ),
        
        // Text Field
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Enter ${label.toLowerCase()}',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVipStatusDisplay() {
    if (widget.customer == null) {
      // For new customers, show info about VIP threshold
      return _buildVipInfoCard();
    }

    // For existing customers, show VIP status and revenue
    return _buildVipStatusCard();
  }

  Widget _buildVipInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'VIP Status Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'VIP status is automatically assigned based on total revenue. Customers become VIP when their total paid invoices reach the threshold amount.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _showVipThresholdSettings,
                icon: Icon(Icons.settings, size: 16, color: Colors.blue[600]),
                label: Text(
                  'Configure VIP Threshold',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVipStatusCard() {
    final progress = _vipThreshold > 0 ? (_customerRevenue / _vipThreshold).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isVip ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isVip ? Colors.green[200]! : Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isVip ? Icons.star : Icons.star_border,
                color: _isVip ? Colors.green[600] : Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isVip ? 'VIP Customer' : 'Regular Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isVip ? Colors.green[800] : Colors.orange[800],
                ),
              ),
              const Spacer(),
              if (_isVip)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'VIP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_isLoadingVipData)
            const Center(
              child: CircularProgressIndicator(),
            )
          else ...[
            // Revenue information
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total Revenue: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(_customerRevenue),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress to VIP
            if (!_isVip) ...[
              Text(
                'Progress to VIP:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
              ),
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.format(_customerRevenue)} / ${CurrencyFormatter.format(_vipThreshold)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showVipThresholdSettings,
                  icon: Icon(Icons.settings, size: 16, color: Colors.blue[600]),
                  label: Text(
                    'Settings',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _refreshVipData,
                  icon: Icon(Icons.refresh, size: 16, color: Colors.grey[600]),
                  label: Text(
                    'Refresh',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showVipThresholdSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: VipThresholdSettings(
                  primaryColor: const Color(0xFF1976D2),
                  onThresholdChanged: () {
                    _loadVipData();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshVipData() async {
    await _loadVipData();
  }
}
