import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'refer.how_it_works'.tr(),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _StepText('refer.step1'.tr()),
          const SizedBox(height: 8),
          _StepText('refer.step2'.tr()),
          const SizedBox(height: 8),
          _StepText('refer.step3'.tr()),
        ],
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  final String text;
  const _StepText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
