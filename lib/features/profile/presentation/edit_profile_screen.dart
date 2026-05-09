import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'male';
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _hasSubmitted = false;
  File? _selectedPhoto;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Name is required';
    }
    if (trimmed.length < 2) {
      return 'Enter a valid name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _selectedPhoto = File(picked.path);
      _removePhoto = false;
    });
  }

  void _removeProfilePhoto() {
    setState(() {
      _selectedPhoto = null;
      _removePhoto = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState is AsyncLoading;
    final user = ref.watch(authProvider);
    final profilePhoto = user?.profilePhoto?.trim();
    final hasRemotePhoto = profilePhoto != null && profilePhoto.isNotEmpty;
    final remotePhotoUrl = hasRemotePhoto
        ? (profilePhoto.startsWith('http')
              ? profilePhoto
              : '${AppConfig.instance.baseUrl.replaceAll('/api', '')}/$profilePhoto')
        : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102213) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A331D).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textPrimary,
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'edit_profile.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasSubmitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // space for sticky button
              children: [
                // Profile Photo Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : AppTheme.hairline,
                                width: 4,
                              ),
                              image: _selectedPhoto != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedPhoto!),
                                      fit: BoxFit.cover,
                                    )
                                  : (!_removePhoto && remotePhotoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(remotePhotoUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 4, right: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1A331D)
                                    : Colors.white,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.photo_camera,
                              color:
                                  Colors.black, // Active tap color effect base
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _pickProfilePhoto,
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.primaryColor,
                        ),
                        label: Text(
                          'edit_profile.change_photo'.tr(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (_selectedPhoto != null || (!_removePhoto && hasRemotePhoto))
                        TextButton.icon(
                          onPressed: _removeProfilePhoto,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text(
                            'Remove photo',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        context,
                        label: 'edit_profile.full_name'.tr(),
                        hintText: 'edit_profile.name_hint'.tr(),
                        controller: _nameController,
                        isDark: isDark,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        context,
                        label: 'edit_profile.email'.tr(),
                        hintText: 'edit_profile.email_hint'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        isDark: isDark,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 24),
                      _buildLockedPhoneField(isDark: isDark),
                      const SizedBox(height: 24),

                      // Gender Selection
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'edit_profile.gender'.tr(),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption(
                              'male',
                              'edit_profile.male'.tr(),
                              Icons.man,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderOption(
                              'female',
                              'edit_profile.female'.tr(),
                              Icons.woman,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderOption(
                              'other',
                              'edit_profile.other'.tr(),
                              Icons.wc,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Sticky Footer Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A331D).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.hairline,
                    ),
                  ),
                ),
                child: CustomButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => _hasSubmitted = true);
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = GoRouter.of(context);
                          await ref
                              .read(profileProvider.notifier)
                              .updateProfile(
                                name: _nameController.text,
                                email: _emailController.text,
                                profilePhoto: _selectedPhoto,
                                removePhoto: _removePhoto,
                              );
                          if (!mounted) {
                            return;
                          }
                          final profileState = ref.read(profileProvider);
                          if (profileState.hasValue) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Profile updated'.tr())),
                            );
                            navigator.pop();
                            return;
                          }
                          if (profileState.hasError) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(profileState.error.toString()),
                              ),
                            );
                          }
                        },
                  isLoading: isLoading,
                  text: 'edit_profile.save'.tr(),
                  borderRadius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    TextEditingController? controller,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark
                  ? AppTheme.textMuted
                  : AppTheme.textMuted, // slate-400
            ),
            filled: true,
            fillColor: isDark ? AppTheme.textPrimary : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor, // primary
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLockedPhoneField({required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'edit_profile.phone'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.textPrimary.withValues(alpha: 0.5)
                : AppTheme.hairline,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '+91 98765 43210',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textMuted
                        : AppTheme.textSecondary,
                    fontSize: 18,
                  ),
                ),
              ),
              Icon(
                Icons.lock,
                color: isDark
                    ? AppTheme.textMuted
                    : AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'edit_profile.phone_locked'.tr(),
            style: TextStyle(
              color: isDark ? AppTheme.textMuted : AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    String value,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 96,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppTheme.textPrimary : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? AppTheme.textSecondary : AppTheme.outline),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : AppTheme.textPrimary)
                    : (isDark
                          ? AppTheme.outline
                          : const Color(0xFF334155)),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
