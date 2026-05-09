import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

/// A single pill — used for chips like "Metal / Plastic / Mixed",
/// "Small / Medium / Large", brand pickers, condition pickers, etc.
///
/// Selected = sage tinted fill + sage border + sage text (not the previous
/// near-invisible pale combo).
/// Unselected = white fill + outline border + dark text.
class AppPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;

  const AppPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColor.primarySurface : AppColor.surface;
    final border = selected ? AppColor.primary : AppColor.outline;
    final fg = selected ? AppColor.primaryDark : AppColor.textPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: border, width: selected ? 1.4 : 1),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row/wrap of [AppPill]s for single-select choice questions.
class AppPillSelector<T> extends StatelessWidget {
  final List<T> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;

  const AppPillSelector({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        return AppPill(
          label: labelBuilder(opt),
          selected: opt == value,
          onTap: () => onChanged(opt),
        );
      }).toList(),
    );
  }
}
