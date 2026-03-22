import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/data/home_models.dart';
import '../bloc/telemetry_bloc.dart';
import '../data/telemetry_models.dart';

/// The Telemetry tab — full explorer with driver comparison.
/// Users pick race → session → driver → metric, then optionally add a second driver.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final HomeBloc _homeBloc;
  late final TelemetryBloc _telemetryBloc;

  // Selections
  RaceModel? _race;
  SessionModel? _session;
  DriverModel? _driver1;
  DriverModel? _driver2;
  String _metric = 'throttle';

  // Available drivers from session (for second driver picker)
  List<DriverModel> _availableDrivers = [];

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc();
    _telemetryBloc = TelemetryBloc();
    _homeBloc.add(LoadRaces(year: DateTime.now().year));
  }

  @override
  void dispose() {
    _homeBloc.close();
    _telemetryBloc.close();
    super.dispose();
  }

  void _loadTelemetry() {
    if (_race == null || _session == null || _driver1 == null) return;
    setState(() { _driver2 = null; });
    _telemetryBloc.add(LoadTelemetry(
      year: DateTime.now().year,
      round: _race!.round,
      session: _session!.key,
      driver: _driver1!.code,
      metric: _metric,
    ));
  }

  void _loadComparison() {
    if (_race == null || _session == null || _driver1 == null || _driver2 == null) return;
    _telemetryBloc.add(LoadComparison(
      year: DateTime.now().year,
      round: _race!.round,
      session: _session!.key,
      driver1: _driver1!.code,
      driver2: _driver2!.code,
      metric: _metric,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _telemetryBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: 'TELEMETRY',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' EXPLORER',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
            ]),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.primaryBorder),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Selection controls ──────────────────────────────────────
              _SelectionCard(
                homeBloc: _homeBloc,
                selectedRace: _race,
                selectedSession: _session,
                selectedDriver: _driver1,
                selectedMetric: _metric,
                onRaceSelected: (race) {
                  setState(() {
                    _race = race;
                    _session = null;
                    _driver1 = null;
                    _driver2 = null;
                    _availableDrivers = [];
                  });
                  _homeBloc.add(RaceSelected(race: race, year: DateTime.now().year));
                },
                onSessionSelected: (session) {
                  setState(() {
                    _session = session;
                    _driver1 = null;
                    _driver2 = null;
                    _availableDrivers = [];
                  });
                  _homeBloc.add(SessionSelected(session: session));
                },
                onDriverSelected: (driver, allDrivers) {
                  setState(() {
                    _driver1 = driver;
                    _driver2 = null;
                    _availableDrivers = allDrivers;
                  });
                  _loadTelemetry();
                },
                onMetricSelected: (metric) {
                  setState(() => _metric = metric);
                  if (_driver1 != null) _loadTelemetry();
                },
              ),

              const SizedBox(height: 16),

              // ── Graph area ────────────────────────────────────────────────
              BlocBuilder<TelemetryBloc, TelemetryState>(
                builder: (context, state) {
                  if (state is TelemetryLoading) {
                    return const GraphLoadingSkeleton();
                  }
                  if (state is TelemetryEmpty) {
                    return _EmptyPlaceholder(message: state.message);
                  }
                  if (state is TelemetryError) {
                    return _EmptyPlaceholder(message: state.message);
                  }
                  if (state is TelemetryLoaded) {
                    return Column(
                      children: [
                        _SingleDriverGraph(data: state.data),
                        const SizedBox(height: 16),
                        // Compare button
                        if (_availableDrivers.length > 1)
                          _CompareButton(
                            driver1: _driver1!,
                            driver2: _driver2,
                            availableDrivers: _availableDrivers,
                            onDriver2Selected: (d) {
                              setState(() => _driver2 = d);
                              _loadComparison();
                            },
                          ),
                        const SizedBox(height: 16),
                        _InsightCard(summary: state.data.summary),
                      ],
                    );
                  }
                  if (state is ComparisonLoaded) {
                    return Column(
                      children: [
                        _ComparisonGraph(data: state.data),
                        const SizedBox(height: 16),
                        if (_availableDrivers.length > 1)
                          _CompareButton(
                            driver1: _driver1!,
                            driver2: _driver2,
                            availableDrivers: _availableDrivers,
                            onDriver2Selected: (d) {
                              setState(() => _driver2 = d);
                              _loadComparison();
                            },
                          ),
                        const SizedBox(height: 16),
                        _InsightCard(summary: state.data.summary),
                      ],
                    );
                  }
                  // Initial state — show placeholder
                  return const _EmptyPlaceholder(
                    message: 'Select a race, session, driver and metric above',
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Selection card ─────────────────────────────────────────────────────────────

class _SelectionCard extends StatelessWidget {
  final HomeBloc homeBloc;
  final RaceModel? selectedRace;
  final SessionModel? selectedSession;
  final DriverModel? selectedDriver;
  final String selectedMetric;
  final void Function(RaceModel) onRaceSelected;
  final void Function(SessionModel) onSessionSelected;
  final void Function(DriverModel, List<DriverModel>) onDriverSelected;
  final void Function(String) onMetricSelected;

  static const _metrics = [
    {'key': 'throttle', 'label': 'Throttle'},
    {'key': 'brake', 'label': 'Brake'},
    {'key': 'speed', 'label': 'Speed'},
    {'key': 'lap_time', 'label': 'Lap Time'},
    {'key': 'top_speed', 'label': 'Top Speed'},
  ];

  const _SelectionCard({
    required this.homeBloc,
    required this.selectedRace,
    required this.selectedSession,
    required this.selectedDriver,
    required this.selectedMetric,
    required this.onRaceSelected,
    required this.onSessionSelected,
    required this.onDriverSelected,
    required this.onMetricSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: homeBloc,
        builder: (context, state) {
          return Column(
            children: [
              // Race selector
              _SelectorTile(
                label: 'RACE',
                value: selectedRace?.name ?? 'Select Race',
                hasValue: selectedRace != null,
                onTap: () => _showRacePicker(context, state),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              // Session selector
              _SelectorTile(
                label: 'SESSION',
                value: selectedSession?.name ?? 'Select Session',
                hasValue: selectedSession != null,
                enabled: selectedRace != null,
                onTap: selectedRace != null
                    ? () => _showSessionPicker(context, state)
                    : null,
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              // Driver selector
              _SelectorTile(
                label: 'DRIVER',
                value: selectedDriver != null
                    ? '${selectedDriver!.code} · ${selectedDriver!.fullName}'
                    : 'Select Driver',
                hasValue: selectedDriver != null,
                enabled: selectedSession != null,
                onTap: selectedSession != null
                    ? () => _showDriverPicker(context, state)
                    : null,
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              // Metric chips
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('METRIC',
                        style: GoogleFonts.barlow(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _metrics.map((m) {
                        final isActive = selectedMetric == m['key'];
                        return GestureDetector(
                          onTap: () => onMetricSelected(m['key']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(m['label']!,
                                style: GoogleFonts.barlow(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRacePicker(BuildContext context, HomeState state) {
    List<RaceModel> races = [];
    if (state is RacesLoaded) races = state.races;

    if (races.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading races...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => _PickerSheet(
          title: 'SELECT RACE',
          items: races.map((r) => _PickerItem(
            label: r.name,
            subtitle: r.date,
            badge: 'R${r.round}',
            onTap: () {
              Navigator.pop(context);
              onRaceSelected(r);
            },
          )).toList(),
          scrollController: controller,
        ),
      ),
    );
  }

  void _showSessionPicker(BuildContext context, HomeState state) {
    List<SessionModel> sessions = [];
    if (state is SessionsLoaded) sessions = state.sessions;

    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading sessions...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PickerSheet(
        title: 'SELECT SESSION',
        items: sessions.map((s) => _PickerItem(
          label: s.name,
          subtitle: s.key,
          onTap: () {
            Navigator.pop(context);
            onSessionSelected(s);
          },
        )).toList(),
      ),
    );
  }

  void _showDriverPicker(BuildContext context, HomeState state) {
    List<DriverModel> drivers = [];
    if (state is DriversLoaded) drivers = state.drivers;

    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading drivers...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => _PickerSheet(
          title: 'SELECT DRIVER',
          items: drivers.map((d) => _PickerItem(
            label: d.fullName,
            subtitle: d.team,
            badge: d.code,
            teamColor: AppColors.teamColor(d.team),
            onTap: () {
              Navigator.pop(context);
              onDriverSelected(d, drivers);
            },
          )).toList(),
          scrollController: controller,
        ),
      ),
    );
  }
}

// ── Selector tile ─────────────────────────────────────────────────────────────

class _SelectorTile extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  final bool enabled;
  final VoidCallback? onTap;

  const _SelectorTile({
    required this.label,
    required this.value,
    this.hasValue = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(label,
                  style: GoogleFonts.barlow(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: enabled
                      ? (hasValue
                          ? AppColors.textPrimary
                          : AppColors.textSecondary)
                      : AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                size: 18,
                color:
                    enabled ? AppColors.textSecondary : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Generic picker sheet ──────────────────────────────────────────────────────

class _PickerItem {
  final String label;
  final String? subtitle;
  final String? badge;
  final Color? teamColor;
  final VoidCallback onTap;

  const _PickerItem({
    required this.label,
    this.subtitle,
    this.badge,
    this.teamColor,
    required this.onTap,
  });
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<_PickerItem> items;
  final ScrollController? scrollController;

  const _PickerSheet({
    required this.title,
    required this.items,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(title,
              style: GoogleFonts.barlow(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary)),
        ),
        const Divider(height: 1, color: AppColors.primaryBorder),
        Flexible(
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: scrollController == null,
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return GestureDetector(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.cardBorder, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      if (item.teamColor != null)
                        Container(
                          width: 3,
                          height: 32,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: item.teamColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      if (item.badge != null && item.teamColor == null)
                        Container(
                          width: 40,
                          height: 32,
                          margin: const EdgeInsets.only(right: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDim,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.badge!,
                              style: GoogleFonts.barlowCondensed(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: GoogleFonts.barlow(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            if (item.subtitle != null)
                              Text(item.subtitle!,
                                  style: GoogleFonts.barlow(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (item.badge != null && item.teamColor != null)
                        Text(item.badge!,
                            style: GoogleFonts.barlowCondensed(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary)),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}

// ── Compare button ────────────────────────────────────────────────────────────

class _CompareButton extends StatelessWidget {
  final DriverModel driver1;
  final DriverModel? driver2;
  final List<DriverModel> availableDrivers;
  final void Function(DriverModel) onDriver2Selected;

  const _CompareButton({
    required this.driver1,
    required this.driver2,
    required this.availableDrivers,
    required this.onDriver2Selected,
  });

  @override
  Widget build(BuildContext context) {
    final others = availableDrivers
        .where((d) => d.code != driver1.code)
        .toList();

    return GestureDetector(
      onTap: () => _showDriverPicker(context, others),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: driver2 != null
                  ? AppColors.primary
                  : AppColors.primaryBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.compare_arrows,
                color: driver2 != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                driver2 != null
                    ? 'Comparing: ${driver1.code} vs ${driver2!.code}'
                    : 'Compare with another driver',
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: driver2 != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showDriverPicker(BuildContext context, List<DriverModel> drivers) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => _PickerSheet(
          title: 'COMPARE WITH',
          items: drivers
              .map((d) => _PickerItem(
                    label: d.fullName,
                    subtitle: d.team,
                    badge: d.code,
                    teamColor: AppColors.teamColor(d.team),
                    onTap: () {
                      Navigator.pop(context);
                      onDriver2Selected(d);
                    },
                  ))
              .toList(),
          scrollController: controller,
        ),
      ),
    );
  }
}

// ── Single driver graph ───────────────────────────────────────────────────────

class _SingleDriverGraph extends StatelessWidget {
  final TelemetryData data;
  const _SingleDriverGraph({required this.data});

  static const double _yAxisWidth = 52.0;
  static const double _graphHeight = 240.0;
  static const double _xAxisHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    if (data.data.isEmpty) return const SizedBox.shrink();

    final isLapBased = data.metric == 'lap_time' || data.metric == 'top_speed';
    final spots = data.data.map((dp) => FlSpot(dp.x, dp.y)).toList();
    final minY = data.data.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    final maxY = data.data.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPadding = yRange < 10 ? 5.0 : yRange * 0.12;
    final effectiveMinY = (minY - yPadding).clamp(0.0, double.infinity);
    final effectiveMaxY = maxY + yPadding;
    final teamColor = AppColors.teamColor(data.team);
    final screenW = MediaQuery.of(context).size.width;

    final chartWidth = isLapBased
        ? (data.data.length * 22.0).clamp(400.0, 4000.0)
        : (screenW * 3.0).clamp(600.0, 6000.0);

    final xInterval = isLapBased
        ? (data.data.length / 8).roundToDouble().clamp(1.0, 10.0)
        : (data.data.last.x / 10).roundToDouble().clamp(100.0, 1000.0);

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
            _buildYAxis(effectiveMinY, effectiveMaxY, data.metric),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: chartWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
                    child: LineChart(LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFF252525), strokeWidth: 1),
                        getDrawingVerticalLine: (_) => const FlLine(
                            color: Color(0xFF1E1E1E), strokeWidth: 0.5),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: _xAxisHeight,
                            interval: xInterval,
                            getTitlesWidget: (v, meta) => SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                isLapBased ? 'L${v.toInt()}' : '${v.toInt()}m',
                                style: GoogleFonts.barlow(
                                    fontSize: 10,
                                    color: const Color(0xFF999999),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: effectiveMinY,
                      maxY: effectiveMaxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.15,
                          color: teamColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: isLapBased),
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
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYAxis(double minY, double maxY, String metric) {
    return Container(
      width: _yAxisWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: _xAxisHeight + 4),
        child: CustomPaint(
          painter: _SimpleYAxisPainter(minY: minY, maxY: maxY, metric: metric),
        ),
      ),
    );
  }
}

// ── Comparison graph ──────────────────────────────────────────────────────────

class _ComparisonGraph extends StatelessWidget {
  final ComparisonData data;
  const _ComparisonGraph({required this.data});

  static const double _yAxisWidth = 52.0;
  static const double _graphHeight = 240.0;
  static const double _xAxisHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    final isLapBased = data.metric == 'lap_time' || data.metric == 'top_speed';
    final d1 = data.driver1;
    final d2 = data.driver2;
    final color1 = AppColors.teamColor(d1.team);
    final color2 = AppColors.teamColor(d2.team);

    final spots1 = d1.data.map((dp) => FlSpot(dp.x, dp.y)).toList();
    final spots2 = d2.data.map((dp) => FlSpot(dp.x, dp.y)).toList();

    final allPoints = [...d1.data, ...d2.data];
    if (allPoints.isEmpty) return const SizedBox.shrink();

    final minY = allPoints.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    final maxY = allPoints.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPadding = yRange < 10 ? 5.0 : yRange * 0.12;
    final effectiveMinY = (minY - yPadding).clamp(0.0, double.infinity);
    final effectiveMaxY = maxY + yPadding;
    final screenW = MediaQuery.of(context).size.width;

    final chartWidth = isLapBased
        ? (spots1.length * 22.0).clamp(400.0, 4000.0)
        : (screenW * 3.0).clamp(600.0, 6000.0);

    final xInterval = isLapBased
        ? (spots1.length / 8).roundToDouble().clamp(1.0, 10.0)
        : (allPoints.last.x / 10).roundToDouble().clamp(100.0, 1000.0);

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: color1, label: '${d1.driver} · ${d1.team}'),
            const SizedBox(width: 16),
            _LegendDot(color: color2, label: '${d2.driver} · ${d2.team}'),
          ],
        ),
        const SizedBox(height: 8),
        Container(
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
                Container(
                  width: _yAxisWidth,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                        right: BorderSide(
                            color: AppColors.cardBorder, width: 1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: _xAxisHeight + 4),
                    child: CustomPaint(
                      painter: _SimpleYAxisPainter(
                          minY: effectiveMinY,
                          maxY: effectiveMaxY,
                          metric: data.metric),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: chartWidth,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
                        child: LineChart(LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (_) => const FlLine(
                                color: Color(0xFF252525), strokeWidth: 1),
                            getDrawingVerticalLine: (_) => const FlLine(
                                color: Color(0xFF1E1E1E), strokeWidth: 0.5),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: _xAxisHeight,
                                interval: xInterval,
                                getTitlesWidget: (v, meta) =>
                                    SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    isLapBased
                                        ? 'L${v.toInt()}'
                                        : '${v.toInt()}m',
                                    style: GoogleFonts.barlow(
                                        fontSize: 10,
                                        color: const Color(0xFF999999),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: effectiveMinY,
                          maxY: effectiveMaxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots1,
                              isCurved: true,
                              curveSmoothness: 0.15,
                              color: color1,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: isLapBased),
                              belowBarData: BarAreaData(show: false),
                            ),
                            LineChartBarData(
                              spots: spots2,
                              isCurved: true,
                              curveSmoothness: 0.15,
                              color: color2,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: isLapBased),
                              belowBarData: BarAreaData(show: false),
                              dashArray: [6, 3], // dashed for driver 2
                            ),
                          ],
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swipe, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('SWIPE TO EXPLORE',
                style: GoogleFonts.barlow(
                    fontSize: 9,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2)),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.barlow(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Shared Y-axis painter ─────────────────────────────────────────────────────

class _SimpleYAxisPainter extends CustomPainter {
  final double minY;
  final double maxY;
  final String metric;

  const _SimpleYAxisPainter(
      {required this.minY, required this.maxY, required this.metric});

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
        color: Color(0xFFAAAAAA),
        fontSize: 10,
        fontFamily: 'Barlow',
        fontWeight: FontWeight.w500);
    const labelCount = 5;
    for (int i = 0; i <= labelCount; i++) {
      final fraction = i / labelCount;
      final value = maxY - (maxY - minY) * fraction;
      final y = size.height * fraction;
      final tp = TextPainter(
        text: TextSpan(text: _fmt(value), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width - 6);
      tp.paint(canvas, Offset(size.width - tp.width - 4, y - tp.height / 2));
      final tick = Paint()..color = const Color(0xFF3A3A3A)..strokeWidth = 1;
      canvas.drawLine(
          Offset(size.width - 2, y), Offset(size.width, y), tick);
    }
  }

  String _fmt(double v) {
    if (metric == 'lap_time') {
      final m = (v ~/ 60).toInt();
      final s = v % 60;
      return m > 0 ? '$m:${s.toStringAsFixed(0)}' : s.toStringAsFixed(1);
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(_SimpleYAxisPainter old) =>
      old.minY != minY || old.maxY != maxY;
}

// ── Insight card ──────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final String summary;
  const _InsightCard({required this.summary});

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
          Row(children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text('AI INSIGHT',
                style: GoogleFonts.barlow(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          Text(summary,
              style: GoogleFonts.barlow(
                  fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

// ── Empty placeholder ─────────────────────────────────────────────────────────

class _EmptyPlaceholder extends StatelessWidget {
  final String message;
  const _EmptyPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
