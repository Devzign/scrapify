import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_stat_card.dart';

/// Responsive metric grid for displaying dashboard statistics.
/// Automatically adjusts columns based on screen width.
class MetricGrid extends StatelessWidget {
  final List<DashboardStatCard> metrics;
  final int? columns;
  final double? spacing;
  final EdgeInsets? padding;

  const MetricGrid({
    Key? key,
    required this.metrics,
    this.columns,
    this.spacing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultColumns = screenWidth < 600 ? 2 : 4;
    final cols = columns ?? defaultColumns;
    final gap = spacing ?? AppTheme.space12;

    return Padding(
      padding: padding ?? const EdgeInsets.all(AppTheme.space16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: 1,
        ),
        itemCount: metrics.length,
        itemBuilder: (context, index) => metrics[index],
      ),
    );
  }
}

/// Single-row metric group for displaying 2-4 metrics.
class MetricRow extends StatelessWidget {
  final List<DashboardStatCard> metrics;
  final EdgeInsets? padding;
  final double? spacing;

  const MetricRow({
    Key? key,
    required this.metrics,
    this.padding,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? AppTheme.space12;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: Row(
        children: List.generate(
          metrics.length,
          (index) => Expanded(
            child: Column(
              children: [
                metrics[index],
                if (index < metrics.length - 1)
                  SizedBox(width: gap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
