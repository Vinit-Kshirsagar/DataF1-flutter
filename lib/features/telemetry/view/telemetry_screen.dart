import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'TELEMETRY — Block 3',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
