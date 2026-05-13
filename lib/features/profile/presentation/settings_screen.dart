import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _isSaving = false;
  final AppPreferences _preferences = AppPreferences();
  bool _didLoadSettings = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadSettings) {
      return;
    }
    _didLoadSettings = true;
    _selectedLanguage = context.locale.languageCode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currentLanguageCode = context.locale.languageCode;
    final savedLanguage = await _preferences.getSelectedLanguage();
    final notificationsEnabled = await _preferences.getNotificationsEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLanguage = savedLanguage ?? currentLanguageCode;
      _notificationsEnabled = notificationsEnabled;
    });
  }

  Future<void> _saveSettings() async {
    final previousLanguageCode = context.locale.languageCode;
    setState(() => _isSaving = true);
    await _preferences.setSelectedLanguage(_selectedLanguage);
    await _preferences.setNotificationsEnabled(_notificationsEnabled);

    if (!mounted) {
      return;
    }

    final nextLocale = Locale(_selectedLanguage);
    if (previousLanguageCode != _selectedLanguage) {
      await context.setLocale(nextLocale);
    }

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            // ── Green gradient header ─────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A5C35), AppColor.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'settings.title'.tr(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: Stack(
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
              Text(
                'settings.language_title'.tr(),
                style: const TextStyle(
                  color: AppColor.deepNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      value: 'en',
                      label: 'English',
                      iconData: Icons.translate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLanguageOption(
                      value: 'hi',
                      label: 'हिंदी',
                      hindiChar: 'अ',
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: AppColor.hairline, height: 1),
              ),

              // Preferences Section
              Text(
                'settings.preferences'.tr(),
                style: const TextStyle(
                  color: AppColor.deepNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),

              _buildPreferenceTile(
                context,
                title: 'settings.notifications'.tr(),
                subtitle: 'settings.notifications_desc'.tr(),
                icon: Icons.notifications_none_outlined,
                value: _notificationsEnabled,
                onChanged: (val) =>
                    setState(() => _notificationsEnabled = val),
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
                    AppColor.backgroundLight,
                    AppColor.backgroundLight,
                    AppColor.backgroundLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: CustomButton(
                onPressed: _isSaving ? null : _saveSettings,
                isLoading: _isSaving,
                text: 'settings.save'.tr(),
                borderRadius: 12,
              ),
            ),
          ),
        ]),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String value,
    required String label,
    IconData? iconData,
    String? hindiChar,
  }) {
    final isSelected = _selectedLanguage == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.cardBorder,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected ? AppTheme.e1 : null,
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
                        ? AppColor.primary
                        : AppColor.backgroundCream,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: iconData != null
                        ? Icon(
                            iconData,
                            size: 26,
                            color: isSelected
                                ? Colors.white
                                : AppColor.textSecondary,
                          )
                        : Text(
                            hindiChar!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : AppColor.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColor.primaryDark : AppColor.deepNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColor.primary,
                    size: 22,
                  ),
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
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColor.cardBorder, width: 1.2),
        boxShadow: AppTheme.e1,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Icon(icon, color: AppColor.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColor.deepNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
            activeTrackColor: AppColor.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColor.outline,
            trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.transparent;
              }
              return AppColor.outline;
            }),
          ),
        ],
      ),
    );
  }
}
