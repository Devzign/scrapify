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
import '../../../core/services/location_service.dart';
import '../domain/models/basket_item.dart';
import '../providers/basket_provider.dart';
import '../providers/booking_provider.dart';
import '../../../core/theme/app_color.dart';

// Labels for each of the 4 required proof shots
const _proofLabels = ['Front', 'Back', 'Left', 'Right'];
const _proofLabelsHi = ['सामने', 'पीछे', 'बायां', 'दायां'];

class UploadPhotoScreen extends ConsumerStatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  ConsumerState<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends ConsumerState<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();

  /// Pick image for [categoryId] at proof-slot [slotIndex].
  Future<void> _pickImage(int categoryId, int slotIndex) async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final position = await _locationService.getCurrentPosition();
      ref.read(bookingProvider.notifier).addCategoryImage(
            categoryId,
            image,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );
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
                    color: AppTheme.alertBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.infoColor,
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

    // Continue is enabled when every category has at least 1 photo
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
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primary.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColor.primary, size: 18),
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
            onPressed: () => context.push(AppRoutes.helpSupport),
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
            const SizedBox(height: 24),

            // Per-category sequential upload cards
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
                  isHindi: isHindi,
                  onAddPhoto: (slotIndex) =>
                      _pickImage(item.category.id, slotIndex),
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
                      _tipChip(FontAwesomeIcons.sun, 'upload.good_lighting'.tr()),
                      _tipChip(
                          FontAwesomeIcons.layerGroup, 'upload.separate_items'.tr()),
                      _tipChip(FontAwesomeIcons.eyeSlash, 'upload.no_blur'.tr()),
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

// ── Per-category card with sequential Front→Back→Left→Right slots ──────────

class _CategoryPhotoCard extends StatelessWidget {
  final BasketItem item;
  final List<XFile> images;
  final bool isHindi;
  final void Function(int slotIndex) onAddPhoto;
  final void Function(int index) onRemovePhoto;

  const _CategoryPhotoCard({
    required this.item,
    required this.images,
    required this.isHindi,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final filled = images.length.clamp(0, 4);
    final allDone = filled >= 4;
    final categoryName =
        isHindi ? item.category.name.hi : item.category.name.en;
    final subName = item.subCategoryName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(
          color: allDone
              ? AppTheme.primaryColor.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: allDone ? 2 : 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
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
              // Progress badge e.g. "2 / 4"
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: allDone
                      ? AppTheme.successColor
                      : AppTheme.hintPeach,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  allDone
                      ? (isHindi ? 'हो गया ✓' : 'Done ✓')
                      : '$filled / 4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: allDone
                        ? AppTheme.primaryDark
                        : AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 4-slot grid ─────────────────────────────────────────────────
          // Slot 0 = Front, 1 = Back, 2 = Left, 3 = Right
          // Filled slots show the photo. Active slot = first unfilled (tappable).
          // Future slots are greyed/locked.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (ctx, i) {
              final label =
                  isHindi ? _proofLabelsHi[i] : _proofLabels[i];
              if (i < filled) {
                // Filled slot — show photo + label + remove button
                return _FilledSlot(
                  image: images[i],
                  label: label,
                  onRemove: () => onRemovePhoto(i),
                );
              } else if (i == filled) {
                // Active slot — tap to add
                return _ActiveSlot(
                  label: label,
                  isHindi: isHindi,
                  onTap: () => onAddPhoto(i),
                );
              } else {
                // Locked slot
                return _LockedSlot(label: label);
              }
            },
          ),
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

// ── Slot widgets ────────────────────────────────────────────────────────────

class _FilledSlot extends StatelessWidget {
  final XFile image;
  final String label;
  final VoidCallback onRemove;

  const _FilledSlot({
    required this.image,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(image.path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Label at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14)),
              color: Colors.black.withValues(alpha: 0.45),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        // ✓ badge top-left
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 10),
          ),
        ),
        // Remove button top-right
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveSlot extends StatelessWidget {
  final String label;
  final bool isHindi;
  final VoidCallback onTap;

  const _ActiveSlot({
    required this.label,
    required this.isHindi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi ? '$label फोटो जोड़ें' : 'Add $label',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isHindi ? 'कैमरा या गैलरी' : 'Camera or gallery',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedSlot extends StatelessWidget {
  final String label;

  const _LockedSlot({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded,
              color: Colors.grey.shade300, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
