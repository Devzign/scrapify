import 'package:go_router/go_router.dart';
import '../storage/app_preferences.dart';
import '../network/api_role_mapper.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/language_selection_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/login_otp_screen.dart';
import '../../features/customer/presentation/customer_dashboard.dart';
import '../../features/pickup/domain/models/pickup_catalog_item.dart';
import '../../features/pickup/presentation/category_selection_screen.dart';
import '../../features/pickup/presentation/dynamic_question_form_screen.dart';
import '../../features/pickup/presentation/upload_photo_screen.dart';
import '../../features/pickup/presentation/select_date_time_screen.dart';
import '../../features/pickup/presentation/subcategory_selection_screen.dart';
import '../../features/pickup/presentation/item_selection_screen.dart';
import '../../features/pickup/presentation/household_item_details_screen.dart';
import '../../features/pickup/presentation/basket_screen.dart';
import '../../features/pickup/presentation/review_booking_screen.dart';
import '../../features/pickup/presentation/payout_method_screen.dart';
import '../../features/pickup/presentation/success_confirmation_screen.dart';
import '../../features/pickup/presentation/pickup_tracking_screen.dart';
import '../../features/pickup/presentation/weight_entry_screen.dart';
import '../../features/pickup/presentation/donation_category_selection_screen.dart';
import '../../features/pickup/presentation/donation_items_screen.dart';
import '../../features/pickup_boy/presentation/pickup_boy_dashboard.dart';
import '../../features/pickup_boy/presentation/pickup_boy_detail_screen.dart';
import '../../features/pickup_boy/presentation/pickup_boy_verification_screen.dart';
import '../../features/warehouse/presentation/warehouse_dashboard.dart';
import '../../features/partner/presentation/partner_dashboard.dart';
import '../../features/pricing/presentation/material_price_list_screen.dart';
import '../../features/pickup/presentation/rate_pickup_screen.dart';
import '../../features/pickup/presentation/pickup_details_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/user_profile_screen.dart';
import '../../features/profile/presentation/saved_addresses_screen.dart';
import '../../features/profile/presentation/add_address_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/faq_screen.dart';
import '../../features/profile/presentation/payment_methods_screen.dart';
import '../../features/profile/presentation/add_edit_payment_screen.dart';
import '../../features/profile/domain/models/payment_method_model.dart';
import '../../features/pickup/domain/models/pickup_request_model.dart';
import '../../features/pickup/presentation/pickup_order_verification_screen.dart';
import '../../features/pickup/presentation/agent_reschedule_request_screen.dart';
import '../../features/pickup/presentation/user_reschedule_pickup_screen.dart';
import '../../features/pickup/presentation/corporate_category_screen.dart';
import '../../features/pickup/presentation/corporate_schedule_screen.dart';
import '../../features/pickup/presentation/corporate_review_screen.dart';
import '../../features/referral/presentation/screens/refer_and_earn_screen.dart';
import '../../features/help_support/presentation/help_support_screen.dart';

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
  static const String basket = '/pickup/basket';
  static const String donationCategorySelection = '/donation/categories';
  static const String donationItems = '/donation/items';
  static const String subCategorySelection = '/pickup/subcategory';
  static const String itemSelection = '/pickup/items';
  static const String householdItemDetails = '/pickup/item-details';
  static const String reviewBooking = '/pickup/review';
  static const String payoutMethod = '/pickup/payout';
  static const String ratePickup = '/pickup/rate';
  static const String pickupDashboard = '/dashboard/pickup';
  static const String warehouseDashboard = '/dashboard/warehouse';
  static const String partnerDashboard = '/dashboard/partner';
  static const String materialPriceList = '/pricing/materials';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String savedAddresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses/add';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String faq = '/profile/faq';
  static const String paymentMethods = '/profile/payment-methods';
  static const String addEditPayment = '/profile/payment-methods/add-edit';
  static const String orderVerification = '/pickup/verification';
  static const String agentReschedule = '/pickup/agent-reschedule';
  static const String userReschedule = '/pickup/user-reschedule';
  static const String pickupBoyDetail = '/pickup-boy/pickups';
  static const String corporateCategory = '/corporate/category';
  static const String corporateSchedule = '/corporate/schedule';
  static const String corporateReview = '/corporate/review';
  static const String referAndEarn = '/refer-and-earn';
  static const String helpSupport = '/help-support';

  static late final GoRouter router;
  static bool _isRouterInitialized = false;
  static const Set<String> _publicRoutes = {
    splash,
    onboarding,
    language,
    role,
    login,
  };

  static void initializeRouter({required String initialLocation}) {
    if (_isRouterInitialized) {
      return;
    }

    router = GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) async {
        final prefs = AppPreferences();
        final token = await prefs.getAuthToken();
        final path = state.fullPath ?? state.uri.path;
        final isPublic = _publicRoutes.contains(path);

        if (token == null || token.isEmpty) {
          if (isPublic) {
            return null;
          }
          return role;
        }

        final roleValue = ApiRoleMapper.toAppRole(
          await prefs.getPrimaryUserRole(),
        );
        if (_isBlockedForRole(path, roleValue)) {
          return _homeForRole(roleValue);
        }

        if (isPublic) {
          return _homeForRole(roleValue);
        }

        return null;
      },
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
          path: corporateCategory,
          builder: (context, state) => const CorporateCategoryScreen(),
        ),
        GoRoute(
          path: corporateSchedule,
          builder: (context, state) => const CorporateScheduleScreen(),
        ),
        GoRoute(
          path: corporateReview,
          builder: (context, state) => const CorporateReviewScreen(),
        ),
        GoRoute(
          path: donationCategorySelection,
          builder: (context, state) => const DonationCategorySelectionScreen(),
        ),
        GoRoute(
          path: donationItems,
          builder: (context, state) => const DonationItemsScreen(),
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
          builder: (context, state) => const SelectAddressTimeScreen(),
        ),
        GoRoute(
          path: successConfirmation,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SuccessConfirmationScreen(
              pickup: extra?['pickup'] as PickupRequestModel?,
              isDonation: extra?['isDonation'] as bool? ?? false,
            );
          },
        ),
        GoRoute(
          path: '$pickupTracking/:pickupId',
          builder: (context, state) {
            final pickupId = int.parse(state.pathParameters['pickupId']!);
            return PickupTrackingScreen(pickupId: pickupId);
          },
        ),
        GoRoute(
          path: pickupDetails,
          builder: (context, state) => const PickupDetailsScreen(),
        ),
        GoRoute(
          path: basket,
          builder: (context, state) => const BasketScreen(),
        ),
        GoRoute(
          path: '$subCategorySelection/:parentId',
          builder: (context, state) {
            final parentId = state.pathParameters['parentId']!;
            return SubCategorySelectionScreen(parentId: int.parse(parentId));
          },
        ),
        GoRoute(
          path: '$itemSelection/:categoryId',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            return ItemSelectionScreen(categoryId: int.parse(categoryId));
          },
        ),
        GoRoute(
          path: householdItemDetails,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return HouseholdItemDetailsScreen(
              item: extra['item'] as PickupCatalogItem,
              parentCategoryName: extra['parentCategoryName'] as String,
              applianceCategoryId: extra['applianceCategoryId'] as int,
              parentCategoryId: extra['parentCategoryId'] as int?,
            );
          },
        ),
        GoRoute(
          path: reviewBooking,
          builder: (context, state) => const ReviewBookingScreen(),
        ),
        GoRoute(
          path: payoutMethod,
          builder: (context, state) => const PayoutMethodScreen(),
        ),
        GoRoute(
          path: '/pickup/weight-entry',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return WeightEntryScreen(
              itemName: extra['itemName'] as String,
              basePrice: extra['basePrice'] as double,
              unit: extra['unit'] as String,
            );
          },
        ),
        GoRoute(
          path: ratePickup,
          builder: (context, state) => const RatePickupScreen(),
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
        GoRoute(
          path: helpSupport,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final orderId = extra?['orderId'] as int?;
            return HelpSupportScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: referAndEarn,
          builder: (context, state) => const ReferAndEarnScreen(),
        ),
        GoRoute(
          path: savedAddresses,
          builder: (context, state) => const SavedAddressesScreen(),
        ),
        GoRoute(
          path: addAddress,
          builder: (context, state) => const AddAddressScreen(),
        ),
        GoRoute(
          path: editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(path: faq, builder: (context, state) => const FaqScreen()),
        GoRoute(
          path: paymentMethods,
          builder: (context, state) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: addEditPayment,
          builder: (context, state) {
            final paymentMethod = state.extra as PaymentMethodModel?;
            return AddEditPaymentScreen(paymentMethod: paymentMethod);
          },
        ),
        GoRoute(
          path: orderVerification,
          builder: (context, state) => const PickupOrderVerificationScreen(),
        ),
        GoRoute(
          path: '$agentReschedule/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return AgentRescheduleRequestScreen(pickupId: id);
          },
        ),
        GoRoute(
          path: '$userReschedule/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return UserReschedulePickupScreen(pickupId: id);
          },
        ),
        GoRoute(
          path: '$pickupBoyDetail/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PickupBoyDetailScreen(pickupId: id);
          },
        ),
        GoRoute(
          path: '$pickupBoyDetail/:id/verify',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PickupBoyVerificationScreen(pickupId: id);
          },
        ),
      ],
    );

    _isRouterInitialized = true;
  }

  static String _homeForRole(String role) {
    switch (role) {
      case 'pickup_partner':
        return pickupDashboard;
      case 'warehouse':
        return warehouseDashboard;
      case 'dealer':
        return partnerDashboard;
      default:
        return customerDashboard;
    }
  }

  static bool _isBlockedForRole(String path, String role) {
    if (path.startsWith('/dashboard/warehouse') ||
        path.startsWith('/warehouse')) {
      return role != 'warehouse';
    }
    if (path.startsWith('/dashboard/pickup') ||
        path.startsWith('/pickup-boy')) {
      return role != 'pickup_partner';
    }
    if (path.startsWith('/dashboard/partner') ||
        path.startsWith('/channel-partner')) {
      return role != 'dealer';
    }
    if (path.startsWith('/pickup') ||
        path.startsWith('/donation') ||
        path.startsWith('/corporate')) {
      return role != 'customer';
    }
    return false;
  }
}
