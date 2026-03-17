import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _selectedGender = 'male';
  final TextEditingController _nameController = TextEditingController(
    text: 'Rahul Kumar',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'rahul.kumar@gmail.com',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF102213)
          : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A331D).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'edit_profile.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
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
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              width: 4,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCGi7qWJ4OHhnKcOEApWEas0qyL2USsJrKxyNYW3trzZ8TQNeP2Jbl3Cx6rJ17IaSJLwE6GO5aN9zYqD1bNmT34NJ0FHuaUsNzniUMXGsxO168tqqMUZDs5Z2J8TsQB6KmT9jmLDXG2wN4aLY3g8eKfQl9_AGYX8qk8UwF-0UIFsNglhJJZoKqUZEefvXvJ0qpXMzFGgP4FQVwKHibcNjfCL2BmuTrpsXDwAHoK6KyAlwXmU6nJ8y3KUD6LR4edjOG7kg5IebtpGAI',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 4, right: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13EC30),
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
                            color: Colors.black, // Active tap color effect base
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, color: Color(0xFF13EC30)),
                      label: Text(
                        'edit_profile.change_photo'.tr(),
                        style: const TextStyle(
                          color: Color(0xFF13EC30),
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
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      context,
                      label: 'edit_profile.email'.tr(),
                      hintText: 'edit_profile.email_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      isDark: isDark,
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
                                : const Color(0xFF0F172A),
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
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13EC30), // primary
                  foregroundColor: Colors.black, // Active tap color effect base
                  elevation: 4,
                  shadowColor: const Color(0xFF13EC30).withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'edit_profile.save'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF94A3B8), // slate-400
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF13EC30), // primary
                width: 2,
              ),
            ),
          ),
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
                color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '+91 98765 43210',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 18,
                  ),
                ),
              ),
              Icon(
                Icons.lock,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF94A3B8),
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
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
              ? const Color(0xFF13EC30).withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF13EC30)
                : (isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
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
                  ? const Color(0xFF13EC30)
                  : (isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark
                          ? const Color(0xFFCBD5E1)
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
