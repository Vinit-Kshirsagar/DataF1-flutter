import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/data/home_models.dart';

class TelemetryScreen extends StatelessWidget {
  final Map<String, dynamic>? params;

  const TelemetryScreen({super.key, this.params});

  @override
  Widget build(BuildContext context) {
    final race = params?['race'] as RaceModel?;
    final session = params?['session'] as SessionModel?;
    final driver = params?['driver'] as DriverModel?;
    final metric = params?['metric'] as MetricModel?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          driver != null ? '${driver.code} · ${metric?.label ?? ''}' : 'TELEMETRY',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.primaryBorder),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (race != null) ...[
              Text(
                race.name,
                style: GoogleFonts.barlow(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${session?.name ?? ''} · ${driver?.fullName ?? ''} · ${metric?.label ?? ''}',
                style: GoogleFonts.barlow(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
            Text(
              'TELEMETRY GRAPH',
              style: GoogleFonts.barlowCondensed(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Block 3 — coming next',
              style: GoogleFonts.barlow(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
