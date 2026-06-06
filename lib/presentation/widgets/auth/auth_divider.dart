import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13)),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
