import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginIntroPanel extends StatelessWidget {
  const LoginIntroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5B99F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMockInputBar(),
              const SizedBox(height: 8),
              _buildMockInputBar(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMockInputBar() {
  return Container(
    width: 150,
    height: 12,
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
