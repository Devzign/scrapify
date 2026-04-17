import 'package:flutter/material.dart';
import 'partner_bottom_nav.dart';

/// Partner Dashboard entry point.
/// Delegates to the full Partner Bottom Navigation shell.
class PartnerDashboard extends StatelessWidget {
  const PartnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const PartnerBottomNav();
  }
}
