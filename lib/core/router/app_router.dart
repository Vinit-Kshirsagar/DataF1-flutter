import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/telemetry/view/telemetry_screen.dart';
import '../../features/telemetry/view/explore_screen.dart';
import '../../features/predictions/view/predictions_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/register_screen.dart';
import '../../features/results/view/results_screen.dart';
import '../widgets/main_shell.dart';

abstract final class AppRoutes {
  static const home        = '/home';
  static const telemetry   = '/telemetry';
  static const explore     = '/explore';
  static const predictions = '/predictions';
  static const profile     = '/profile';
  static const login       = '/login';
  static const register    = '/register';
  static const results     = '/results';
}

final authStateNotifier = ValueNotifier<bool>(false);

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  refreshListenable: authStateNotifier,
  redirect: (context, state) {
    final isAuthenticated = authStateNotifier.value;
    if (state.matchedLocation == AppRoutes.profile && !isAuthenticated) {
      return AppRoutes.login;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => _slidePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (context, state) => _slidePage(state, const RegisterScreen()),
    ),
    // Full-screen routes — no bottom nav
    GoRoute(
      path: AppRoutes.telemetry,
      name: 'telemetry',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _fadePage(state, TelemetryScreen(params: extra));
      },
    ),
    GoRoute(
      path: AppRoutes.results,
      name: 'results',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return _slidePage(state, ResultsScreen(
          year: extra['year'] as int,
          round: extra['round'] as int,
          raceName: extra['raceName'] as String,
        ));
      },
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.explore,
          name: 'explore',
          pageBuilder: (context, state) => _fadePage(state, const ExploreScreen()),
        ),
        GoRoute(
          path: AppRoutes.predictions,
          name: 'predictions',
          pageBuilder: (context, state) => _fadePage(state, const PredictionsScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) => _fadePage(state, const ProfileScreen()),
        ),
      ],
    ),
  ],
);

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child),
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurveTween(curve: Curves.easeInOut).animate(animation)),
            child: child),
  );
}
