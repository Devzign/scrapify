import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

extension PartnerLocaleX on BuildContext {
  bool get isHindi => locale.languageCode == 'hi';

  String partnerText(String english, String hindi) {
    return isHindi ? hindi : english;
  }
}

String localizedPartnerStatus(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return context.partnerText('Active', 'सक्रिय');
    case 'inactive':
      return context.partnerText('Inactive', 'निष्क्रिय');
    case 'available':
      return context.partnerText('Available', 'उपलब्ध');
    case 'online':
      return context.partnerText('Online', 'ऑनलाइन');
    case 'offline':
      return context.partnerText('Offline', 'ऑफलाइन');
    case 'busy':
      return context.partnerText('Busy', 'व्यस्त');
    case 'pending':
      return context.partnerText('Pending', 'लंबित');
    case 'approved':
      return context.partnerText('Approved', 'मंजूर');
    case 'rejected':
      return context.partnerText('Rejected', 'अस्वीकृत');
    case 'assigned':
      return context.partnerText('Assigned', 'असाइन');
    case 'completed':
      return context.partnerText('Completed', 'पूरा हुआ');
    case 'cancelled':
      return context.partnerText('Cancelled', 'रद्द');
    case 'rescheduled':
      return context.partnerText('Rescheduled', 'पुनर्निर्धारित');
    default:
      return status;
  }
}
