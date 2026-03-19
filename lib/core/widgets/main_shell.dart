import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.telemetry)) return 1;
    if (location.startsWith(AppRoutes.predictions)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0; // home
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.telemetry);
      case 2:
        context.go(AppRoutes.predictions);
      case 3:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.primaryBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onTap(context, index),
          items: [
            _navItem(Icons.home_outlined, Icons.home, 'HOME', currentIndex == 0),
            _navItem(Icons.show_chart_outlined, Icons.show_chart, 'EXPLORE',
                currentIndex == 1),
            _navItem(Icons.emoji_events_outlined, Icons.emoji_events,
                'PREDICT', currentIndex == 2),
            _navItem(Icons.person_outline, Icons.person, 'PROFILE',
                currentIndex == 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    bool isActive,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(outlinedIcon, size: 24),
      activeIcon: Icon(filledIcon, size: 24, color: AppColors.primary),
      label: label,
    );
  }
}
