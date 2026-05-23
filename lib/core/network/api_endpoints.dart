import 'dart:io';

class ApiEndpoints {
  const ApiEndpoints._();

  static String get googleMapsApiKey {
    if (Platform.isAndroid) {
      return 'AIzaSyBc66d5mRq_tau0aKJQyZnSXtZY_tVuppY';
    } else if (Platform.isIOS) {
      return 'AIzaSyBc66d5mRq_tau0aKJQyZnSXtZY_tVuppY';
    }
    return '';
  }

  static const String authSendOtp = '/auth/send-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authRegisterSendOtp = '/auth/register/send-otp';
  static const String authRegisterVerifyOtp = '/auth/register/verify-otp';
  static const String authLoginSendOtp = '/auth/login/send-otp';
  static const String authLoginVerifyOtp = '/auth/login/verify-otp';
  static const String authUserTypes = '/auth/user-types';
  static const String authProfile = '/auth/profile';
  static const String authProfileUpdate = '/auth/profile/update';
  static const String authLogout = '/auth/logout';
  static const String authProfileAddresses = '/auth/profile/addresses';
  static const String authProfilePaymentDetails =
      '/auth/profile/payment-details';
  static const String authProfileBankDetails = '/auth/profile/bank-details';
  static const String authProfileKyc = '/auth/profile/kyc';

  static const String states = '/states';
  static const String cities = '/cities';
  static const String categories = '/categories';
  static const String subcategories = '/subcategories';
  static const String homeApplianceDetails = '/home-appliances/details';
  static const String homeApplianceEstimate = '/home-appliances/estimate';
  static const String categoryTypes = '/category-types';

  static const String pickupRequest = '/pickup-requests';
  static const String pickupRequests = '/pickup-requests';
  static const String donationRequest = '/donation-request';
  static const String donationRequests = '/donation-requests';
  static const String donationProducts = '/donation-products';
  static const String corporateBookings = '/corporate-bookings';
  static const String corporateBookingOptions = '/corporate-bookings/options';
  static const String helpSupport = '/help-support';
  static const String referralValidateCode = '/referral/validate-code';
  static const String referralMyCode = '/referral/my-code';
  static const String referralMyRewards = '/referral/my-rewards';
  static const String referralValidateCoupon = '/referral/validate-coupon';
  static const String adminReferralSettings = '/admin/referral-settings';
  static const String adminReferrals = '/admin/referrals';
  static const String adminReferralCoupons = '/admin/referral-coupons';
  static const String pickupRequestStats = '/pickup-requests/stats';
  static const String pickupImagesUpload = '/pickup-images/upload';
  static const String pickupSlots = '/pickup-slots';
  static const String serviceableCities = '/serviceable-cities';

  static const String pickupBoyDashboard = '/pickup-boy/dashboard';
  static const String pickupBoyAssignments = '/pickup-boy/assignments';
  static const String pickupBoyLocation = '/pickup-boy/location';
  static const String pickupBoyStatus = '/pickup-boy/status';

  static const String adminPickups = '/admin/pickups';
  static const String adminPickupBoys = '/admin/pickup-boys';
  static const String adminUserTypeVisibility = '/admin/user-types';

  static const String appSettings = '/app-settings';
  static const String appSettingsLanguage = '/app-settings/language';

  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsFcmToken = '/notifications/fcm-token';

  static const String warehouse = '/warehouse';

  // Warehouse App (admin/warehouse/channel_partner)
  static const String warehouseAppProfile = '/warehouse/app/profile';
  static const String warehouseAppOrders = '/warehouse/app/orders';
  static const String warehouseAppAvailablePickupBoys =
      '/warehouse/app/available-pickup-boys';
  static const String warehouseAppAssignPickupBoy =
      '/warehouse/app/assign-pickup-boy';

  static String warehouseAppReassign(int pickupId) {
    return '/warehouse/app/pickups/$pickupId/reassign';
  }

  // Pickup Boy — new endpoints
  static String pickupBoyUpdateAssignmentStatus(int id) {
    return '${pickupBoyPickupById(id)}/update-status';
  }

  static String pickupBoyUpdateFinalPrice(int id) {
    return '${pickupBoyPickupById(id)}/update-final-price';
  }

  static String pickupBoyAddItem(int id) {
    return '${pickupBoyPickupById(id)}/add-item';
  }

  static String authProfileAddressById(int id) {
    return '$authProfileAddresses/$id';
  }

  static String authProfilePaymentDetailById(int id) {
    return '$authProfilePaymentDetails/$id';
  }

  static String categoryById(int id) {
    return '$categories/$id';
  }

  static String categoryTypeById(int id) {
    return '$categoryTypes/$id';
  }

  static String pickupRequestById(int id) {
    return '$pickupRequests/$id';
  }

  static String pickupRequestReschedule(int id) {
    return '${pickupRequestById(id)}/reschedule';
  }

  static String pickupRequestImages(int id) {
    return '${pickupRequestById(id)}/images';
  }

  static String pickupRequestTracking(int id) {
    return '${pickupRequestById(id)}/tracking';
  }

  static String pickupRequestCancel(int id) {
    return '${pickupRequestById(id)}/cancel';
  }

  static String pickupRequestReview(int id) {
    return '${pickupRequestById(id)}/review';
  }

  static String donationRequestById(int id) {
    return '$donationRequests/$id';
  }

  static String pickupRequestCloneAsDonation(int id) {
    return '${pickupRequestById(id)}/clone-as-donation';
  }

  static String pickupImageById(int id) {
    return '/pickup-images/$id';
  }

  static String pickupBoyPickupById(int id) {
    return '/pickup-boy/pickups/$id';
  }

  static String pickupBoyAccept(int id) {
    return '${pickupBoyPickupById(id)}/accept';
  }

  static String pickupBoyReject(int id) {
    return '${pickupBoyPickupById(id)}/reject';
  }

  static String pickupBoyUpdateStatus(int id) {
    return '${pickupBoyPickupById(id)}/status';
  }

  static String pickupBoyVerify(int id) {
    return '${pickupBoyPickupById(id)}/verify';
  }

  static String adminAssignPickup(int id) {
    return '$adminPickups/$id/assign';
  }

  static String notificationRead(String id) {
    return '$notifications/$id/read';
  }

  static String notificationById(String id) {
    return '$notifications/$id';
  }

  static String warehouseById(int id) {
    return '$warehouse/$id';
  }

  static String warehouseInventory(int id) {
    return '${warehouseById(id)}/inventory';
  }

  static String warehouseInventorySummary(int id) {
    return '${warehouseById(id)}/inventory/summary';
  }

  static String adminReferralSettingsById(int id) {
    return '$adminReferralSettings/$id';
  }

  static String adminReferralCouponCancel(int id) {
    return '$adminReferralCoupons/$id/cancel';
  }
}
