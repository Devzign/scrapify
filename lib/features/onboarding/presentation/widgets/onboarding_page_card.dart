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
          SizedBox(height: 42.h),
          Text(
            page.titleEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              color: AppColor.deepNavy,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            page.titleHi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.deepNavy.withValues(alpha: 0.82),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.textSecondary,
              height: 1.45,
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
      height: 330.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.emeraldMoss.withValues(alpha: 0.2),
                    AppColor.emeraldMoss.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 300.h,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(color: Colors.white, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: AppColor.deepNavy.withValues(alpha: 0.09),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26.r),
              child: ColoredBox(
                color: AppColor.onboardingBackground,
                child: Image.asset(page.imageAsset, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            bottom: 14.h,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColor.emeraldMoss.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColor.deepNavy.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 34.r,
              width: 34.r,
              decoration: BoxDecoration(
                color: AppColor.emeraldMoss.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.badgeIcon,
                color: AppColor.emeraldMoss,
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
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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
