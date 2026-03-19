import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/telemetry/view/telemetry_screen.dart';
import '../../features/predictions/view/predictions_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/register_screen.dart';
import '../widgets/main_shell.dart';

// Route name constants — use these everywhere instead of string literals
abstract final class AppRoutes {
  static const home = '/home';
  static const telemetry = '/telemetry';
  static const predictions = '/predictions';
  static const profile = '/profile';
  static const login = '/login';
  static const register = '/register';
}

// Auth state notifier — updated by AuthBloc
final authStateNotifier = ValueNotifier<bool>(false);

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  refreshListenable: authStateNotifier,
  redirect: (context, state) {
    final isAuthenticated = authStateNotifier.value;
    final isGoingToProfile = state.matchedLocation == AppRoutes.profile;

    // Only /profile requires auth
    if (isGoingToProfile && !isAuthenticated) {
      return AppRoutes.login;
    }

    // Don't redirect authenticated users away from auth pages
    // (they might want to switch accounts)
    return null;
  },
  routes: [
    // ── Auth screens (outside shell) ─────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => _slidePage(
        state,
        const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (context, state) => _slidePage(
        state,
        const RegisterScreen(),
      ),
    ),

    // ── Main shell with bottom nav ────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.telemetry,
          name: 'telemetry',
          pageBuilder: (context, state) =>
              _fadePage(state, const TelemetryScreen()),
        ),
        GoRoute(
          path: AppRoutes.predictions,
          name: 'predictions',
          pageBuilder: (context, state) =>
              _fadePage(state, const PredictionsScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) =>
              _fadePage(state, const ProfileScreen()),
        ),
      ],
    ),
  ],
);

// ── Page transition helpers ──────────────────────────────────────────────────

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurveTween(curve: Curves.easeInOut).animate(animation)),
        child: child,
      );
    },
  );
}
