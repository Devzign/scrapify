import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

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
            ? const Color(0xFF1A2C1E).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF111812), // text-main
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A), // slate-900
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
              left: 16,
              right: 16,
              top: 24,
              bottom: 128,
            ),
            children: [
              // Language Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'settings.language_title'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      value: 'en',
                      label: 'English',
                      iconData: Icons.translate,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLanguageOption(
                      value: 'hi',
                      label: 'हिंदी',
                      hindiChar: 'अ',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Color(0xFFE5E7EB), height: 1), // gray-200
              ),

              // Preferences Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'settings.preferences'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildPreferenceTile(
                context,
                title: 'settings.notifications'.tr(),
                subtitle: 'settings.notifications_desc'.tr(),
                icon: Icons.notifications_none_outlined,
                value: _notificationsEnabled,
                isDark: isDark,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              const SizedBox(height: 16),
              _buildPreferenceTile(
                context,
                title: 'settings.dark_mode'.tr(),
                subtitle: 'settings.dark_mode_desc'.tr(),
                icon: Icons.dark_mode_outlined,
                value: _darkModeEnabled,
                isDark: isDark,
                onChanged: (val) => setState(() => _darkModeEnabled = val),
              ),
            ],
          ),

          // Fixed Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                32,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    isDark ? const Color(0xFF102213) : const Color(0xFFF6F8F6),
                    isDark ? const Color(0xFF102213) : const Color(0xFFF6F8F6),
                    (isDark ? const Color(0xFF102213) : const Color(0xFFF6F8F6))
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13EC30), // primary
                  foregroundColor: Colors.black,
                  elevation: 8,
                  shadowColor: const Color(0xFF13EC30).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'settings.save'.tr(),
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

  Widget _buildLanguageOption({
    required String value,
    required String label,
    required bool isDark,
    IconData? iconData,
    String? hindiChar,
  }) {
    final isSelected = _selectedLanguage == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF13EC30).withValues(alpha: 0.05) // primary/5
              : (isDark ? const Color(0xFF1A2C1E) : Colors.white), // surface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF13EC30) // primary
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE5E7EB)), // border
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF13EC30).withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF13EC30)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF3F4F6)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: iconData != null
                        ? Icon(
                            iconData,
                            size: 28,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFF9CA3AF),
                          )
                        : Text(
                            hindiChar!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? const Color(0xFF13EC30) : Colors.black)
                        : (isDark ? Colors.white : const Color(0xFF111812)),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: -12,
                right: -12,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF13EC30),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF13EC30).withValues(alpha: 0.1)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF13EC30) : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF111812),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF13EC30),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark
                ? const Color(0xFF374151)
                : const Color(0xFFE5E7EB),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.transparent;
              }
              return isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
            }),
          ),
        ],
      ),
    );
  }
}
