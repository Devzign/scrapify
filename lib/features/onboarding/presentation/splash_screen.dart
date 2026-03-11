import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (token != null && token.isNotEmpty) {
      // Get role from saved user data
      final userStr = prefs.getString('user_data');
      String role = 'customer';
      if (userStr != null) {
        try {
          final userData = Map<String, dynamic>.from(
            (const JsonDecoder().convert(userStr)) as Map,
          );
          final roles = userData['roles'] as List?;
          if (roles != null && roles.isNotEmpty) {
            role = roles.first.toString();
          }
        } catch (e) {
          debugPrint('Error parsing user data: $e');
        }
      }

      if (role == 'pickup_partner' || role == 'pickup_boy') {
        context.go(AppRoutes.pickupDashboard);
      } else if (role == 'warehouse') {
        context.go(AppRoutes.warehouseDashboard);
      } else if (role == 'dealer') {
        context.go(AppRoutes.partnerDashboard);
      } else {
        context.go(AppRoutes.customerDashboard);
      }
    } else if (hasSeenOnboarding) {
      context.go(AppRoutes.language);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.recycle,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Scrapify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'splash.subtitle'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.leaf,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'splash.footer'.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
