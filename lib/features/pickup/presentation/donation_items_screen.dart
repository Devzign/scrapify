import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/models/basket_item.dart';
import '../providers/donation_provider.dart';

class DonationItemsScreen extends ConsumerStatefulWidget {
  const DonationItemsScreen({super.key});

  @override
  ConsumerState<DonationItemsScreen> createState() =>
      _DonationItemsScreenState();
}

class _DonationItemsScreenState extends ConsumerState<DonationItemsScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _pickImage(int categoryId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      ref.read(donationProvider.notifier).updateItemImage(categoryId, image);
    }
  }

  @override
  void initState() {
    super.initState();
    _notesController.text = ref.read(donationProvider).notes;
    _notesController.addListener(() {
      ref.read(donationProvider.notifier).updateNotes(_notesController.text);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donationState = ref.watch(donationProvider);
    final selectedItems = donationState.items;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.locale.languageCode == 'hi' ? 'दान की वस्तुएं' : 'Donate Items',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step 1 of 2',
                style: TextStyle(
                  color: AppTheme.primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Item Cards
                    ...selectedItems.map((item) => _DonationItemUploadCard(
                          item: item,
                          onAddPhoto: () => _pickImage(item.category.id),
                        )),

                    const SizedBox(height: 12),

                    // Other Items Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB).withOpacity(0.4),
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.locale.languageCode == 'hi' ? 'अन्य वस्तुएं' : 'Other Items',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notes Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.locale.languageCode == 'hi'
                                ? 'टिप्पणियां (वैकल्पिक)'
                                : 'Notes (optional)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe condition, quantity, or specific pickup instructions...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Footer Button
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
                  onPressed: () {
                    context.push(AppRoutes.selectDateTime);
                  },
                  text: 'Proceed to Schedule',
                  minHeight: 64,
                  borderRadius: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationItemUploadCard extends StatelessWidget {
  final BasketItem item;
  final VoidCallback onAddPhoto;

  const _DonationItemUploadCard({
    required this.item,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _iconForSlug(item.category.slug),
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  context.locale.languageCode == 'hi'
                      ? item.category.name.hi
                      : item.category.name.en,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text(
                  'Add Photo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  backgroundColor: const Color(0xFFEAF6EE),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onAddPhoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: item.image != null
                  ? Image.file(
                      File(item.image!.path),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: AppTheme.textSecondary.withOpacity(0.4),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.locale.languageCode == 'hi'
                                ? 'आवश्यक'
                                : 'REQUIRED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForSlug(String slug) {
    switch (slug) {
      case 'clothes':
        return Icons.checkroom_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'newspapers':
        return Icons.newspaper_rounded;
      case 'electronics':
        return Icons.devices_other_rounded;
      case 'plastic':
        return Icons.recycling_rounded;
      default:
        return Icons.volunteer_activism_rounded;
    }
  }
}
