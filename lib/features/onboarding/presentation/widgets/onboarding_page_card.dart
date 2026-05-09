import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../view_models/onboarding_view_model.dart';

class OnboardingPageCard extends StatelessWidget {
  final OnboardingPageContent page;

  const OnboardingPageCard({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IllustrationPanel(page: page),
          SizedBox(height: 36.h),
          Text(
            page.titleEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColor.deepNavy,
              height: 1.15,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            page.titleHi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  final OnboardingPageContent page;

  const _IllustrationPanel({required this.page});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft sage halo behind the card.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.primary.withValues(alpha: 0.16),
                    AppColor.primary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Solid white card — no more transparency wash.
          Container(
            width: double.infinity,
            height: 310.h,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: AppColor.cardBorder),
              boxShadow: AppTheme.e2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: ColoredBox(
                color: AppColor.backgroundCream,
                child: Image.asset(page.imageAsset, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            right: 14.w,
            bottom: 16.h,
            child: _FloatingBadge(page: page),
          ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final OnboardingPageContent page;

  const _FloatingBadge({required this.page});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColor.primaryLight, width: 1.2),
        boxShadow: AppTheme.e2,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 36.r,
              width: 36.r,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.badgeIcon,
                color: AppColor.primary,
                size: 20.r,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.badgeLabel,
                  style: TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  page.badgeValue,
                  style: TextStyle(
                    color: AppColor.deepNavy,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
