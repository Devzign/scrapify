import 'package:flutter/material.dart';
import 'warehouse_bottom_nav.dart';

/// Warehouse Dashboard entry point.
/// Delegates to the full Warehouse Bottom Navigation shell.
class WarehouseDashboard extends StatelessWidget {
  const WarehouseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const WarehouseBottomNav();
  }
}
