import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/domain/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/corporate_provider.dart';

class CorporateDetailsScreen extends ConsumerStatefulWidget {
  const CorporateDetailsScreen({super.key});

  @override
  ConsumerState<CorporateDetailsScreen> createState() =>
      _CorporateDetailsScreenState();
}

class _CorporateDetailsScreenState
    extends ConsumerState<CorporateDetailsScreen> {
  late final TextEditingController _companyNameController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactMobileController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _gstController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactMobileController = TextEditingController();
    _contactEmailController = TextEditingController();
    _gstController = TextEditingController();
    _notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _syncControllersFromBooking(ref.read(corporateBookingProvider));
      await ref.read(authProvider.notifier).fetchProfile();
      if (!mounted) return;
      _prefillFromUser(ref.read(authProvider));
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    _contactEmailController.dispose();
    _gstController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    final booking = ref.watch(corporateBookingProvider);
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider).settings;
    final meetingTypes =
        (settings['corporate_meeting_types'] as List<dynamic>?)
            ?.map((e) => e.toString().trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const ['in_person', 'google_meet', 'skype'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prefillFromUser(user, meetingTypes: meetingTypes);
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColor.primary,
              size: 18,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isHindi ? 'कंपनी विवरण' : 'Company Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    controller: _companyNameController,
                    label: isHindi
                        ? 'कंपनी का नाम (वैकल्पिक)'
                        : 'Company Name (Optional)',
                    hint: isHindi
                        ? 'कंपनी का नाम दर्ज करें'
                        : 'Enter company name',
                    onChanged: ref
                        .read(corporateBookingProvider.notifier)
                        .setCompanyName,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _contactNameController,
                    label: isHindi ? 'संपर्क नाम *' : 'Contact Name *',
                    hint: isHindi
                        ? 'संपर्क व्यक्ति का नाम'
                        : 'Enter contact name',
                    onChanged: ref
                        .read(corporateBookingProvider.notifier)
                        .setContactName,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _contactMobileController,
                    label: isHindi ? 'मोबाइल नंबर *' : 'Mobile Number *',
                    hint: isHindi
                        ? 'मोबाइल नंबर दर्ज करें'
                        : 'Enter mobile number',
                    keyboardType: TextInputType.phone,
                    onChanged: ref
                        .read(corporateBookingProvider.notifier)
                        .setContactMobile,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _contactEmailController,
                    label: isHindi ? 'ईमेल पता *' : 'Email Address *',
                    hint: isHindi
                        ? 'ईमेल पता दर्ज करें'
                        : 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: ref
                        .read(corporateBookingProvider.notifier)
                        .setContactEmail,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _gstController,
                    label: isHindi
                        ? 'जीएसटी नंबर (वैकल्पिक)'
                        : 'GST Number (Optional)',
                    hint: isHindi ? 'GSTIN दर्ज करें' : 'Enter GSTIN',
                    onChanged: ref
                        .read(corporateBookingProvider.notifier)
                        .setGstNumber,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<String>(
                    label: isHindi ? 'मीटिंग प्रकार *' : 'Meeting Type *',
                    value: booking.meetingType.isEmpty
                        ? null
                        : booking.meetingType,
                    items: meetingTypes,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(corporateBookingProvider.notifier)
                            .setMeetingType(value);
                      }
                    },
                    itemLabel: (v) => v.replaceAll('_', ' '),
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _notesController,
                    label: isHindi ? 'नोट्स (वैकल्पिक)' : 'Notes (Optional)',
                    hint: isHindi
                        ? 'अतिरिक्त जानकारी लिखें'
                        : 'Write additional details',
                    maxLines: 3,
                    onChanged: ref
                        .read(corporateBookingProvider.notifier)
                        .setNotes,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                onPressed: booking.isReadyToSubmit
                    ? () => context.push(AppRoutes.corporateReview)
                    : null,
                text: isHindi ? 'बुकिंग समीक्षा' : 'REVIEW BOOKING',
                minHeight: 56,
                borderRadius: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T item) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey('${label}_$value'),
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outline),
            ),
          ),
        ),
      ],
    );
  }

  void _prefillFromUser(User? user, {List<String>? meetingTypes}) {
    final booking = ref.read(corporateBookingProvider);
    final notifier = ref.read(corporateBookingProvider.notifier);
    final resolvedMeetingTypes = meetingTypes ?? _meetingTypesFromSettings();

    if (booking.companyName.trim().isEmpty &&
        (user?.name.trim().isNotEmpty ?? false)) {
      notifier.setCompanyName(user!.name);
    }
    if (booking.contactName.trim().isEmpty &&
        (user?.name.trim().isNotEmpty ?? false)) {
      notifier.setContactName(user!.name);
    }
    if (booking.contactMobile.trim().isEmpty &&
        (user?.phone.trim().isNotEmpty ?? false)) {
      notifier.setContactMobile(user!.phone);
    }
    if (booking.contactEmail.trim().isEmpty &&
        (user?.email?.trim().isNotEmpty ?? false)) {
      notifier.setContactEmail(user!.email!);
    }
    if (booking.meetingType.trim().isEmpty && resolvedMeetingTypes.isNotEmpty) {
      notifier.setMeetingType(resolvedMeetingTypes.first);
    }

    _syncControllersFromBooking(ref.read(corporateBookingProvider));
  }

  List<String> _meetingTypesFromSettings() {
    final settings = ref.read(settingsProvider).settings;
    return (settings['corporate_meeting_types'] as List<dynamic>?)
            ?.map((e) => e.toString().trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const ['in_person', 'google_meet', 'skype'];
  }

  void _syncControllersFromBooking(CorporateBookingState booking) {
    _setControllerValue(_companyNameController, booking.companyName);
    _setControllerValue(_contactNameController, booking.contactName);
    _setControllerValue(_contactMobileController, booking.contactMobile);
    _setControllerValue(_contactEmailController, booking.contactEmail);
    _setControllerValue(_gstController, booking.gstNumber ?? '');
    _setControllerValue(_notesController, booking.notes ?? '');
  }

  void _setControllerValue(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}
