class ApiEndpoints {
  const ApiEndpoints._();

  static const String googleMapsApiKey =
      'AIzaSyBxn1MmF7oFUFI4fgTYxhm1M9GB4YPQZwY';

  static const String authSendOtp = '/auth/send-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
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
  static const String items = '/items';
  static const String homeApplianceDetails = '/home-appliances/details';
  static const String categoryTypes = '/category-types';

  static const String pickupRequest = '/pickup-request';
  static const String pickupRequests = '/pickup-requests';
  static const String donationRequest = '/donation-request';
  static const String donationRequests = '/donation-requests';
  static const String corporateBookings = '/corporate-bookings';
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
}
