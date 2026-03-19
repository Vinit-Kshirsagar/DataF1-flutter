import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'PREDICTIONS — Block 5',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
