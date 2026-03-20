import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/telemetry_bloc.dart';
import '../data/telemetry_models.dart';
import '../../home/data/home_models.dart';

class TelemetryScreen extends StatefulWidget {
  final Map<String, dynamic>? params;

  const TelemetryScreen({super.key, this.params});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  late final TelemetryBloc _bloc;
  String? _activeMetric;

  @override
  void initState() {
    super.initState();
    _bloc = TelemetryBloc();

    final p = widget.params;
    if (p != null) {
      final race = p['race'] as RaceModel?;
      final session = p['session'] as SessionModel?;
      final driver = p['driver'] as DriverModel?;
      final metric = p['metric'] as MetricModel?;
      final year = p['year'] as int? ?? DateTime.now().year;

      if (race != null && session != null && driver != null && metric != null) {
        _activeMetric = metric.key;
        _bloc.add(LoadTelemetry(
          year: year,
          round: race.round,
          session: session.key,
          driver: driver.code,
          metric: metric.key,
        ));
      }
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.params?['driver'] as DriverModel?;
    final race = widget.params?['race'] as RaceModel?;
    final session = widget.params?['session'] as SessionModel?;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(driver, race, session),
        body: BlocBuilder<TelemetryBloc, TelemetryState>(
          builder: (context, state) {
            return Column(
              children: [
                _MetricChipRow(
                  activeMetric: _activeMetric,
                  onSelected: (key) {
                    setState(() => _activeMetric = key);
                    _bloc.add(ChangeTelemetryMetric(metric: key));
                  },
                ),
                const Divider(height: 1, color: AppColors.primaryBorder),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    DriverModel? driver,
    RaceModel? race,
    SessionModel? session,
  ) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: AppColors.textSecondary, size: 18),
        onPressed: () => context.go(AppRoutes.home),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (driver != null)
            Text(
              driver.fullName,
              style: GoogleFonts.barlowCondensed(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          if (race != null && session != null)
            Text(
              '${race.name} · ${session.name}',
              style: GoogleFonts.barlow(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.primaryBorder),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TelemetryState state) {
    if (state is TelemetryLoading) {
      return const GraphLoadingSkeleton();
    }
    if (state is TelemetryEmpty) {
      return _EmptyState(message: state.message);
    }
    if (state is TelemetryError) {
      return _ErrorState(
        message: state.message,
        onRetry: () {
          final p = widget.params;
          if (p != null) {
            final race = p['race'] as RaceModel?;
            final session = p['session'] as SessionModel?;
            final driver = p['driver'] as DriverModel?;
            final year = p['year'] as int? ?? DateTime.now().year;
            if (race != null && session != null && driver != null) {
              _bloc.add(LoadTelemetry(
                year: year,
                round: race.round,
                session: session.key,
                driver: driver.code,
                metric: _activeMetric ?? 'throttle',
              ));
            }
          }
        },
      );
    }
    if (state is TelemetryLoaded) {
      return _TelemetryContent(data: state.data);
    }
    return const SizedBox.shrink();
  }
}

// ── Metric chip selector ──────────────────────────────────────────────────────

class _MetricChipRow extends StatelessWidget {
  final String? activeMetric;
  final void Function(String key) onSelected;

  static const _metrics = [
    {'key': 'throttle', 'label': 'Throttle'},
    {'key': 'brake', 'label': 'Brake'},
    {'key': 'speed', 'label': 'Speed'},
    {'key': 'lap_time', 'label': 'Lap Time'},
    {'key': 'top_speed', 'label': 'Top Speed'},
  ];

  const _MetricChipRow({required this.activeMetric, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final m = _metrics[i];
          final isActive = activeMetric == m['key'];
          return GestureDetector(
            onTap: () => onSelected(m['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              child: Text(
                m['label']!,
                style: GoogleFonts.barlow(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class _TelemetryContent extends StatelessWidget {
  final TelemetryData data;

  const _TelemetryContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsRow(data: data),
          const SizedBox(height: 16),
          _TelemetryGraph(data: data),
          const SizedBox(height: 6),
          // Scroll hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swipe, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                'SWIPE TO EXPLORE',
                style: GoogleFonts.barlow(
                  fontSize: 9,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // AI Summary — ALWAYS present, NEVER remove
          _InsightSummaryCard(summary: data.summary, partial: data.partial),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final TelemetryData data;

  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final teamColor = AppColors.teamColor(data.team);
    return Row(
      children: [
        Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(
            color: teamColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.team,
                style: GoogleFonts.barlow(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${data.metricLabel} · ${data.session} · ${data.year}',
                style: GoogleFonts.barlow(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (data.fastestLap != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'FASTEST LAP',
                style: GoogleFonts.barlow(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatLapTime(data.fastestLap!),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatLapTime(double seconds) {
    final mins = (seconds ~/ 60);
    final secs = seconds % 60;
    if (mins > 0) {
      return '$mins:${secs.toStringAsFixed(3).padLeft(6, '0')}';
    }
    return secs.toStringAsFixed(3);
  }
}

// ── Scrollable Telemetry Graph ────────────────────────────────────────────────
// Fixed Y-axis on left, chart scrolls horizontally

class _TelemetryGraph extends StatelessWidget {
  final TelemetryData data;

  const _TelemetryGraph({required this.data});

  // Layout constants
  static const double _yAxisWidth = 52.0;
  static const double _graphHeight = 260.0;
  static const double _xAxisHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    if (data.data.isEmpty) {
      return const _EmptyState(
          message: 'Data not available for selected parameters');
    }

    final isLapBased =
        data.metric == 'lap_time' || data.metric == 'top_speed';
    final spots = data.data.map((dp) => FlSpot(dp.x, dp.y)).toList();

    final minY = data.data.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    final maxY = data.data.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPadding = yRange < 10 ? 5.0 : yRange * 0.12;
    final effectiveMinY = (minY - yPadding).clamp(0, double.infinity);
    final effectiveMaxY = maxY + yPadding;

    final teamColor = AppColors.teamColor(data.team);

    // Chart width — wider = more detail when scrolling
    final chartWidth = isLapBased
        ? (data.data.length * 20.0).clamp(400.0, 4000.0)
        : (MediaQuery.of(context).size.width * 2.5).clamp(600.0, 4000.0);

    // X-axis interval
    final xInterval = isLapBased
        ? (data.data.length / 10).roundToDouble().clamp(1, 10)
        : (data.data.last.x / 10).roundToDouble().clamp(5, 200);

    final chartData = LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0xFF2A2A2A),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (_) => const FlLine(
          color: Color(0xFF222222),
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        // Y-axis rendered separately as fixed widget — hidden here
        leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _xAxisHeight,
            interval: xInterval.toDouble(),
            getTitlesWidget: (v, meta) {
              final label = isLapBased ? 'L${v.toInt()}' : '${v.toInt()}m';
              return SideTitleWidget(
                axisSide: AxisSide.bottom,
                child: Text(
                  label,
                  style: GoogleFonts.barlow(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: effectiveMinY.toDouble(),
      maxY: effectiveMaxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBorder:
              const BorderSide(color: AppColors.primaryBorder),
          getTooltipItems: (touchedSpots) => touchedSpots
              .map((s) => LineTooltipItem(
                    '${_valueLabel(s.y)} ${data.metricUnit}',
                    GoogleFonts.barlow(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ))
              .toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: data.metric != 'brake',
          isStepLineChart: false,
          curveSmoothness: data.metric == 'brake' ? 0.0 : 0.15,
          color: teamColor,
          barWidth: isLapBased ? 2.5 : 1.8,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: isLapBased,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 3,
              color: teamColor,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                teamColor.withValues(alpha: 0.18),
                teamColor.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );

    return Container(
      height: _graphHeight + _xAxisHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fixed Y-axis — never scrolls ──────────────────────────────
            Container(
              width: _yAxisWidth,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  right: BorderSide(color: AppColors.cardBorder, width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: _xAxisHeight + 4),
                child: CustomPaint(
                  painter: _YAxisPainter(
                    minY: effectiveMinY.toDouble(),
                    maxY: effectiveMaxY,
                    metric: data.metric,
                  ),
                ),
              ),
            ),

            // ── Scrollable chart ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: chartWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
                    child: LineChart(
                      chartData,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _valueLabel(double v) {
    if (data.metric == 'lap_time') {
      final m = (v ~/ 60).toInt();
      final s = v % 60;
      return m > 0
          ? '$m:${s.toStringAsFixed(3).padLeft(6, '0')}'
          : s.toStringAsFixed(3);
    }
    return v.toStringAsFixed(1);
  }
}

// ── Fixed Y-axis painter ──────────────────────────────────────────────────────

class _YAxisPainter extends CustomPainter {
  final double minY;
  final double maxY;
  final String metric;

  const _YAxisPainter({
    required this.minY,
    required this.maxY,
    required this.metric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      color: Color(0xFFAAAAAA), // clearly readable on dark bg
      fontSize: 10,
      fontFamily: 'Barlow',
      fontWeight: FontWeight.w500,
    );

    const labelCount = 5;
    for (int i = 0; i <= labelCount; i++) {
      final fraction = i / labelCount;
      final value = maxY - (maxY - minY) * fraction;
      final y = size.height * fraction;

      final label = _formatValue(value);
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      )..layout(maxWidth: size.width - 6);

      tp.paint(
        canvas,
        Offset(size.width - tp.width - 4, y - tp.height / 2),
      );

      // Draw small tick mark
      final tickPaint = Paint()
        ..color = const Color(0xFF3A3A3A)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(size.width - 2, y),
        Offset(size.width, y),
        tickPaint,
      );
    }
  }

  String _formatValue(double v) {
    if (metric == 'lap_time') {
      final m = (v ~/ 60).toInt();
      final s = v % 60;
      return m > 0 ? '$m:${s.toStringAsFixed(0)}' : s.toStringAsFixed(1);
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(_YAxisPainter old) =>
      old.minY != minY || old.maxY != maxY || old.metric != metric;
}

// ── AI Insight Summary Card ────────────────────────────────────────────────────
// Core differentiator — ALWAYS present, NEVER remove

class _InsightSummaryCard extends StatelessWidget {
  final String summary;
  final bool partial;

  const _InsightSummaryCard({required this.summary, required this.partial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI INSIGHT',
                style: GoogleFonts.barlow(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
              ),
              if (partial) ...[
                const Spacer(),
                Text(
                  'PARTIAL DATA',
                  style: GoogleFonts.barlow(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: GoogleFonts.barlow(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.bar_chart_outlined,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.barlow(
                color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.wifi_off_outlined,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.barlow(
                color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'TAP TO RETRY',
                style: GoogleFonts.barlow(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
