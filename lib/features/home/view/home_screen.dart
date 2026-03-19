import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../bloc/home_bloc.dart';
import '../data/home_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(LoadRaces(year: DateTime.now().year));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is SelectionComplete) {
            // Navigate to telemetry with selection params
            context.go(
              '/telemetry',
              extra: {
                'race': state.race, 'year': state.year,
                'session': state.session,
                'driver': state.driver,
                'metric': state.metric,
              },
            );
            // Reset for next visit
            _bloc.add(LoadRaces(year: DateTime.now().year));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return CustomScrollView(
                  slivers: [
                    _buildHeader(context, state),
                    SliverToBoxAdapter(
                      child: _buildBody(context, state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, HomeState state) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.primaryBorder),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'DATA',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'F1',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _subtitleForState(state),
                style: GoogleFonts.barlow(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleForState(HomeState state) {
    if (state is SessionsLoaded || state is SessionsLoading) {
      return 'SELECT SESSION';
    } else if (state is DriversLoaded || state is DriversLoading) {
      return 'SELECT DRIVER';
    } else if (state is MetricSelectionReady) {
      return 'SELECT METRIC';
    }
    return 'SELECT RACE';
  }

  // ── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading ||
        state is SessionsLoading ||
        state is DriversLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: ListLoadingSkeleton(itemCount: 10),
      );
    }

    if (state is HomeError) {
      return _buildError(context, state.message);
    }

    if (state is RacesLoaded) {
      return _buildRaceList(context, state.races);
    }

    if (state is SessionsLoaded) {
      return _buildSessionList(context, state);
    }

    if (state is DriversLoaded) {
      return _buildDriverList(context, state);
    }

    if (state is MetricSelectionReady) {
      return _buildMetricList(context, state);
    }

    return const ListLoadingSkeleton();
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
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
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _bloc.add(LoadRaces(year: DateTime.now().year)),
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

  // ── Race list ─────────────────────────────────────────────────────────────

  Widget _buildRaceList(BuildContext context, List<RaceModel> races) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('${DateTime.now().year} SEASON'),
        ...races.map((race) => _RaceCard(
              race: race,
              onTap: () => _bloc.add(RaceSelected(race: race, year: DateTime.now().year)),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Session list ──────────────────────────────────────────────────────────

  Widget _buildSessionList(BuildContext context, SessionsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(context),
        _selectionBreadcrumb(state.selectedRace.name),
        _sectionLabel('SESSIONS'),
        ...state.sessions.map((session) => _SelectionTile(
              title: session.name,
              subtitle: session.key,
              onTap: () => _bloc.add(SessionSelected(session: session)),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Driver list ───────────────────────────────────────────────────────────

  Widget _buildDriverList(BuildContext context, DriversLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(context),
        _selectionBreadcrumb(
          '${state.selectedRace.name} · ${state.selectedSession.name}',
        ),
        _sectionLabel('DRIVERS'),
        ...state.drivers.map((driver) => _DriverTile(
              driver: driver,
              onTap: () => _bloc.add(DriverSelected(driver: driver)),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Metric list ───────────────────────────────────────────────────────────

  Widget _buildMetricList(BuildContext context, MetricSelectionReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(context),
        _selectionBreadcrumb(
          '${state.selectedRace.name} · ${state.selectedDriver.code}',
        ),
        _sectionLabel('TELEMETRY METRIC'),
        ...state.metrics.map((metric) => _SelectionTile(
              title: metric.label,
              subtitle: metric.unit,
              onTap: () => _bloc.add(MetricSelected(metric: metric)),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: GoogleFonts.barlow(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _selectionBreadcrumb(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(
        text,
        style: GoogleFonts.barlow(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GestureDetector(
        onTap: () => _bloc.add(SelectionStepBack()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              'BACK',
              style: GoogleFonts.barlow(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Race card ─────────────────────────────────────────────────────────────────

class _RaceCard extends StatelessWidget {
  final RaceModel race;
  final VoidCallback onTap;

  const _RaceCard({required this.race, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Round badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'R${race.round}',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Race info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.name,
                    style: GoogleFonts.barlow(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${race.circuit} · ${race.date}',
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic selection tile ────────────────────────────────────────────────────

class _SelectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.barlow(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.barlow(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Driver tile ───────────────────────────────────────────────────────────────

class _DriverTile extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onTap;

  const _DriverTile({required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final teamColor = AppColors.teamColor(driver.team);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Team color bar
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: teamColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Driver code badge
            Text(
              driver.code,
              style: GoogleFonts.barlowCondensed(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            // Driver details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.fullName,
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    driver.team,
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
