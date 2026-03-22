import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../data/results_models.dart';
import '../data/results_repository.dart';

class ResultsScreen extends StatefulWidget {
  final int year;
  final int round;
  final String raceName;

  const ResultsScreen({
    super.key,
    required this.year,
    required this.round,
    required this.raceName,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _repo = ResultsRepository();

  // Cache both session results
  RaceResultsData? _raceData;
  RaceResultsData? _qualiData;
  String? _raceError;
  String? _qualiError;
  bool _raceLoading = true;
  bool _qualiLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadRace();
    _loadQuali();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadRace() async {
    try {
      final data = await _repo.getResults(
          year: widget.year, round: widget.round, session: 'R');
      if (mounted) setState(() { _raceData = data; _raceLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _raceError = 'Unable to load data. Tap to retry'; _raceLoading = false; });
    }
  }

  Future<void> _loadQuali() async {
    try {
      final data = await _repo.getResults(
          year: widget.year, round: widget.round, session: 'Q');
      if (mounted) setState(() { _qualiData = data; _qualiLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _qualiError = 'Unable to load data. Tap to retry'; _qualiLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textSecondary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.raceName,
                style: GoogleFonts.barlowCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: Colors.white)),
            Text('${widget.year} · Round ${widget.round}',
                style: GoogleFonts.barlow(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: GoogleFonts.barlow(
              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          unselectedLabelStyle: GoogleFonts.barlow(fontSize: 12),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [Tab(text: 'RACE'), Tab(text: 'QUALIFYING')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildResultsList(
            loading: _raceLoading,
            error: _raceError,
            data: _raceData,
            onRetry: () { setState(() { _raceLoading = true; _raceError = null; }); _loadRace(); },
            isRace: true,
          ),
          _buildResultsList(
            loading: _qualiLoading,
            error: _qualiError,
            data: _qualiData,
            onRetry: () { setState(() { _qualiLoading = true; _qualiError = null; }); _loadQuali(); },
            isRace: false,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList({
    required bool loading,
    required String? error,
    required RaceResultsData? data,
    required VoidCallback onRetry,
    required bool isRace,
  }) {
    if (loading) return _buildShimmer();
    if (error != null) return _buildError(error, onRetry);
    if (data == null || data.results.isEmpty) {
      return _buildEmpty('Data not available for selected parameters');
    }

    final finishers = data.results.where((r) => !r.isDNF).toList();
    final dnfs = data.results.where((r) => r.isDNF).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Podium (top 3 only for Race)
        if (isRace && finishers.length >= 3)
          _PodiumRow(
            p1: finishers[0],
            p2: finishers[1],
            p3: finishers[2],
          ),

        // Full results
        ...finishers.map((r) => _DriverResultTile(result: r, isRace: isRace)),

        // DNFs section
        if (dnfs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('DID NOT FINISH',
                style: GoogleFonts.barlow(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary)),
          ),
          ...dnfs.map((r) => _DriverResultTile(result: r, isRace: isRace)),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (_, i) => Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildError(String msg, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(msg,
              style: GoogleFonts.barlow(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('TAP TO RETRY',
                  style: GoogleFonts.barlow(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_outlined,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(msg,
              style: GoogleFonts.barlow(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Podium widget ─────────────────────────────────────────────────────────────

class _PodiumRow extends StatelessWidget {
  final DriverResult p1;
  final DriverResult p2;
  final DriverResult p3;

  const _PodiumRow({required this.p1, required this.p2, required this.p3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // P2
          Expanded(child: _PodiumStep(result: p2, height: 80, medal: '🥈')),
          const SizedBox(width: 8),
          // P1
          Expanded(child: _PodiumStep(result: p1, height: 100, medal: '🏆')),
          const SizedBox(width: 8),
          // P3
          Expanded(child: _PodiumStep(result: p3, height: 64, medal: '🥉')),
        ],
      ),
    );
  }
}

class _PodiumStep extends StatelessWidget {
  final DriverResult result;
  final double height;
  final String medal;

  const _PodiumStep({
    required this.result,
    required this.height,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    final teamColor = AppColors.teamColor(result.team);
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(result.driverCode,
            style: GoogleFonts.barlowCondensed(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Colors.white)),
        Text(result.team,
            style: GoogleFonts.barlow(
                fontSize: 9, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: teamColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            border: Border.all(color: teamColor.withValues(alpha: 0.4), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            'P${result.position}',
            style: GoogleFonts.barlowCondensed(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: teamColor),
          ),
        ),
      ],
    );
  }
}

// ── Driver result tile ────────────────────────────────────────────────────────

class _DriverResultTile extends StatelessWidget {
  final DriverResult result;
  final bool isRace;

  const _DriverResultTile({required this.result, required this.isRace});

  @override
  Widget build(BuildContext context) {
    final teamColor = AppColors.teamColor(result.team);
    final pos = result.position;
    final isDNF = result.isDNF;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Team color bar
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: isDNF ? AppColors.inactive : teamColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          // Position
          SizedBox(
            width: 44,
            child: Center(
              child: isDNF
                  ? Text('DNF',
                      style: GoogleFonts.barlowCondensed(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted))
                  : Text(
                      pos != null ? 'P$pos' : '—',
                      style: GoogleFonts.barlowCondensed(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: pos != null && pos <= 3
                              ? teamColor
                              : AppColors.textPrimary),
                    ),
            ),
          ),
          // Driver info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(result.driverCode,
                          style: GoogleFonts.barlowCondensed(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: isDNF
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      Text(result.driverFullName,
                          style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                      if (result.fastestLap) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9B30FF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('FL',
                              style: GoogleFonts.barlow(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF9B30FF))),
                        ),
                      ],
                    ],
                  ),
                  Text(result.team,
                      style: GoogleFonts.barlow(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          // Right side — gap or points
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isRace && result.gapToLeader != null)
                  Text(result.gapToLeader!,
                      style: GoogleFonts.barlow(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500))
                else if (!isRace && result.gridPosition != null)
                  Text('Grid ${result.gridPosition}',
                      style: GoogleFonts.barlow(
                          fontSize: 11, color: AppColors.textSecondary)),
                if (isRace && result.points > 0)
                  Text('+${result.points.toStringAsFixed(0)} pts',
                      style: GoogleFonts.barlowCondensed(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
