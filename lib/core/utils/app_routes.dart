import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/language_selection_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/login_otp_screen.dart';
import '../../features/dashboard/presentation/customer_dashboard.dart';
import '../../features/pickup/presentation/category_selection_screen.dart';
import '../../features/pickup/presentation/dynamic_question_form_screen.dart';
import '../../features/pickup/presentation/upload_photo_screen.dart';
import '../../features/pickup/presentation/select_date_time_screen.dart';
import '../../features/pickup/presentation/success_confirmation_screen.dart';
import '../../features/pickup/presentation/pickup_tracking_screen.dart';
import '../../features/dashboard/presentation/pickup_boy_dashboard.dart';
import '../../features/dashboard/presentation/warehouse_dashboard.dart';
import '../../features/dashboard/presentation/partner_dashboard.dart';
import '../../features/pricing/presentation/material_price_list_screen.dart';
import '../../features/pickup/presentation/rate_pickup_screen.dart';
import '../../features/pickup/presentation/pickup_details_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/user_profile_screen.dart';
// New screens
import '../../features/pickup_boy/presentation/pickup_boy_detail_screen.dart';
import '../../features/pickup_boy/presentation/pickup_boy_verification_screen.dart';
import '../../features/warehouse/presentation/warehouse_requests_screen.dart';
import '../../features/warehouse/presentation/warehouse_request_detail_screen.dart';
import '../../features/warehouse/presentation/warehouse_pickup_boys_screen.dart';
import '../../features/channel_partner/presentation/partner_orders_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String language = '/language';
  static const String role = '/role';
  static const String login = '/login';
  static const String customerDashboard = '/dashboard/customer';
  static const String categorySelection = '/pickup/category';
  static const String questionForm = '/pickup/questions';
  static const String uploadPhoto = '/pickup/upload-photo';
  static const String selectDateTime = '/pickup/date-time';
  static const String successConfirmation = '/pickup/success';
  static const String pickupTracking = '/pickup/tracking';
  static const String pickupDetails = '/pickup/details';
  static const String ratePickup = '/pickup/rate';
  static const String pickupDashboard = '/dashboard/pickup';
  static const String warehouseDashboard = '/dashboard/warehouse';
  static const String partnerDashboard = '/dashboard/partner';
  static const String materialPriceList = '/pricing/materials';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  // Pickup Boy
  static const String pickupBoyDetail = '/pickup-boy/pickups/:id';
  static const String pickupBoyVerify = '/pickup-boy/pickups/:id/verify';
  // Warehouse
  static const String warehouseRequests = '/warehouse/requests';
  static const String warehouseRequestDetail = '/warehouse/requests/:id';
  static const String warehousePickupBoys = '/warehouse/pickup-boys';
  // Channel Partner
  static const String partnerOrders = '/partner/orders';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: language,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: role,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final role = extra?['role'] as String?;
          return LoginOtpScreen(role: role);
        },
      ),
      GoRoute(
        path: customerDashboard,
        builder: (context, state) => const CustomerDashboard(),
      ),
      GoRoute(
        path: pickupDashboard,
        builder: (context, state) => const PickupBoyDashboard(),
      ),
      GoRoute(
        path: warehouseDashboard,
        builder: (context, state) => const WarehouseDashboard(),
      ),
      GoRoute(
        path: partnerDashboard,
        builder: (context, state) => const PartnerDashboard(),
      ),
      GoRoute(
        path: categorySelection,
        builder: (context, state) => const CategorySelectionScreen(),
      ),
      GoRoute(
        path: questionForm,
        builder: (context, state) => const DynamicQuestionFormScreen(),
      ),
      GoRoute(
        path: uploadPhoto,
        builder: (context, state) => const UploadPhotoScreen(),
      ),
      GoRoute(
        path: selectDateTime,
        builder: (context, state) => const SelectDateTimeScreen(),
      ),
      GoRoute(
        path: successConfirmation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SuccessConfirmationScreen(pickupId: extra?['pickup_id'] as int?);
        },
      ),
      GoRoute(
        path: pickupTracking,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PickupTrackingScreen(pickupId: extra?['pickup_id'] as int?);
        },
      ),
      GoRoute(
        path: pickupDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PickupDetailsScreen(pickupId: extra?['pickup_id'] as int?);
        },
      ),
      GoRoute(
        path: ratePickup,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RatePickupScreen(pickupId: extra?['pickup_id'] as int?);
        },
      ),
      GoRoute(
        path: materialPriceList,
        builder: (context, state) => const MaterialPriceListScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const UserProfileScreen(),
      ),

      // --- Pickup Boy Routes ---
      GoRoute(
        path: '/pickup-boy/pickups/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PickupBoyDetailScreen(pickupId: id);
        },
      ),
      GoRoute(
        path: '/pickup-boy/pickups/:id/verify',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PickupBoyVerificationScreen(pickupId: id);
        },
      ),

      // --- Warehouse Routes ---
      GoRoute(
        path: warehouseRequests,
        builder: (context, state) => const WarehouseRequestsScreen(),
      ),
      GoRoute(
        path: '/warehouse/requests/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return WarehouseRequestDetailScreen(requestId: id);
        },
      ),
      GoRoute(
        path: warehousePickupBoys,
        builder: (context, state) => const WarehousePickupBoysScreen(),
      ),

      // --- Channel Partner Routes ---
      GoRoute(
        path: partnerOrders,
        builder: (context, state) => const PartnerOrdersScreen(),
      ),
    ],
  );
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Screen: $title')),
    );
  }
}
