import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../formatters/indian_mobile_formatter.dart';

class LoginPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const LoginPhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: errorText != null ? Colors.red : Colors.grey.shade300,
          width: errorText != null ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(30),
        color: enabled ? Colors.white : Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.flag,
                  color: Colors.green.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '+91',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Container(height: 24, width: 1, color: Colors.grey.shade300),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              enabled: enabled,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IndianMobileFormatter(),
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'login.phone_hint'.tr(),
                hintStyle: const TextStyle(fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
