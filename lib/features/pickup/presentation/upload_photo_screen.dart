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
import '../providers/basket_provider.dart';
import '../providers/booking_provider.dart';

class UploadPhotoScreen extends ConsumerStatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  ConsumerState<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends ConsumerState<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int categoryId) async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      ref.read(bookingProvider.notifier).addCategoryImage(categoryId, image);
    }
  }

  Future<ImageSource?> _showSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  context.locale.languageCode == 'hi'
                      ? 'कैमरा खोलें'
                      : 'Take Photo',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                title: Text(
                  context.locale.languageCode == 'hi'
                      ? 'गैलरी से चुनें'
                      : 'Choose from Gallery',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final basketItems = ref.watch(basketProvider);
    final isHindi = context.locale.languageCode == 'hi';

    // Every category must have at least 1 photo
    final allCovered =
        basketItems.isNotEmpty &&
        basketItems.every(
          (item) =>
              (bookingState.categoryImages[item.category.id]?.isNotEmpty ??
              false),
        );

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
          'upload.title'.tr(),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'common.help'.tr(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'upload.heading'.tr().toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'upload.desc'.tr(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // Hint banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.hintPeach,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    color: Color(0xFFC2410C),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isHindi
                          ? 'प्रत्येक श्रेणी के लिए कम से कम 1 फोटो आवश्यक है।'
                          : 'At least 1 photo required per category for accurate pricing.',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFC2410C).withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Per-category upload cards
            if (basketItems.isEmpty)
              Center(
                child: Text(
                  isHindi ? 'बास्केट खाली है।' : 'No items in basket.',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            else
              ...basketItems.map(
                (item) => _CategoryPhotoCard(
                  item: item,
                  images: bookingState.categoryImages[item.category.id] ?? [],
                  onAddPhoto: () => _pickImage(item.category.id),
                  onRemovePhoto: (idx) => ref
                      .read(bookingProvider.notifier)
                      .removeCategoryImage(item.category.id, idx),
                ),
              ),

            const SizedBox(height: 16),

            // Tips card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.cardBorderRadius,
                border: AppTheme.cardBorder,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.circleInfo,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'upload.tips_title'.tr().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tipChip(
                        FontAwesomeIcons.sun,
                        'upload.good_lighting'.tr(),
                      ),
                      _tipChip(
                        FontAwesomeIcons.layerGroup,
                        'upload.separate_items'.tr(),
                      ),
                      _tipChip(
                        FontAwesomeIcons.eyeSlash,
                        'upload.no_blur'.tr(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomButton(
            onPressed: allCovered
                ? () => context.push(AppRoutes.selectDateTime)
                : null,
            text: 'common.continue'.tr().toUpperCase(),
            trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
            minHeight: 60,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }

  Widget _tipChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _CategoryPhotoCard extends StatelessWidget {
  final BasketItem item;
  final List<XFile> images;
  final VoidCallback onAddPhoto;
  final void Function(int index) onRemovePhoto;

  const _CategoryPhotoCard({
    required this.item,
    required this.images,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    final hasPhoto = images.isNotEmpty;
    final categoryName = isHindi
        ? item.category.name.hi
        : item.category.name.en;
    final subName = item.subCategoryName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(
          color: hasPhoto
              ? AppTheme.primaryColor.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: hasPhoto ? 2 : 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForSlug(item.category.slug),
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subName != null && subName.isNotEmpty)
                      Text(
                        subName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Required / Done badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: hasPhoto
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasPhoto
                      ? (isHindi ? 'हो गया ✓' : 'Done ✓')
                      : (isHindi ? 'आवश्यक' : 'Required'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: hasPhoto
                        ? const Color(0xFF14532D)
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photos row (horizontal scroll) or empty placeholder
          if (hasPhoto) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length + 1, // +1 for add button
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  if (i == images.length) {
                    // Add more photos button
                    return GestureDetector(
                      onTap: onAddPhoto,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.7,
                              ),
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isHindi ? 'और जोड़ें' : 'Add More',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(images[i].path),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto(i),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ] else ...[
            // Empty placeholder — tap to add
            GestureDetector(
              onTap: onAddPhoto,
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: AppTheme.cardBorder,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isHindi ? 'फोटो जोड़ें' : 'Add Photo',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHindi ? 'कैमरा या गैलरी से' : 'Camera or gallery',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForSlug(String slug) {
    switch (slug.toLowerCase()) {
      case 'e-waste':
      case 'electronics':
        return Icons.devices_other_rounded;
      case 'metal-scrap':
      case 'metal':
      case 'iron-steel':
        return Icons.hardware_rounded;
      case 'plastic-scrap':
      case 'plastic':
        return Icons.recycling_rounded;
      case 'paper-carton-scrap':
      case 'paper':
        return Icons.newspaper_rounded;
      case 'hazardous-waste':
        return Icons.warning_amber_rounded;
      case 'vehicle-machinery-waste':
        return Icons.two_wheeler_rounded;
      case 'furniture-scrap':
        return Icons.chair_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}
