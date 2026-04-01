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
import '../../features/pickup/presentation/subcategory_selection_screen.dart';
import '../../features/pickup/presentation/item_selection_screen.dart';
import '../../features/pickup/presentation/household_item_details_screen.dart';
import '../../features/pickup/presentation/basket_screen.dart';
import '../../features/pickup/presentation/review_booking_screen.dart';
import '../../features/pickup/presentation/payout_method_screen.dart';
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
import '../../features/profile/presentation/saved_addresses_screen.dart';
import '../../features/profile/presentation/add_address_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/faq_screen.dart';
import '../../features/profile/presentation/payment_methods_screen.dart';
import '../../features/profile/presentation/add_edit_payment_screen.dart';
import '../../features/profile/domain/models/payment_method_model.dart';
import '../../features/pickup/domain/models/pickup_catalog_item.dart';

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

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
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
        builder: (context, state) => const SelectAddressTimeScreen(),
      ),
      GoRoute(
        path: successConfirmation,
        builder: (context, state) => const SuccessConfirmationScreen(),
      ),
      GoRoute(
        path: pickupTracking,
        builder: (context, state) => const PickupTrackingScreen(),
      ),
      GoRoute(
        path: pickupDetails,
        builder: (context, state) => const PickupDetailsScreen(),
      ),
      GoRoute(path: basket, builder: (context, state) => const BasketScreen()),
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
    ],
  );
}
