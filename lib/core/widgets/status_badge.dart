import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status badge component for displaying pickup/request status.
/// Supports multiple status types with semantic colors.
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool outlined;
  final double? padding;

  /// Predefined status types and their colors
  static const Map<String, Map<String, Color>> statusColors = {
    'assigned': {
      'bg': Color(0xFFE6EEF7),
      'text': Color(0xFF3D6B9A),
    },
    'pending': {
      'bg': Color(0xFFFCEFD8),
      'text': Color(0xFFD88B3C),
    },
    'completed': {
      'bg': Color(0xFFDFF1E6),
      'text': Color(0xFF3F9D6B),
    },
    'cancelled': {
      'bg': Color(0xFFFBE7E6),
      'text': Color(0xFFC44A47),
    },
    'in_progress': {
      'bg': Color(0xFFE6EEF7),
      'text': Color(0xFF3D6B9A),
    },
  };

  const StatusBadge({
    Key? key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.outlined = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = statusColors[status.toLowerCase()] ?? statusColors['pending']!;
    final bgColor = backgroundColor ?? colors['bg']!;
    final txtColor = textColor ?? colors['text']!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding ?? AppTheme.space10,
        vertical: padding ?? AppTheme.space6,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : bgColor,
        border: outlined ? Border.all(color: txtColor, width: 1) : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: txtColor, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: txtColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
