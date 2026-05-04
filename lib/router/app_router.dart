import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/asha/asha_coming_soon_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/companion/companion_screen.dart';
import '../screens/entry/mode_selection_screen.dart';
import '../screens/entry/startup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/log/daily_log_screen.dart';
import '../screens/music/music_screen.dart';
import '../screens/napkin/napkin_finder_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/setup_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/common/asmita_bottom_nav.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const StartupScreen(),
    ),
    GoRoute(
      path: '/mode',
      builder: (context, state) => const ModeSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
    GoRoute(
      path: '/asha-coming-soon',
      builder: (context, state) => const AshaComingSoonScreen(),
    ),
    GoRoute(path: '/music', builder: (context, state) => const MusicScreen()),
    GoRoute(
      path: '/napkin',
      builder: (context, state) => const NapkinFinderScreen(),
    ),
    GoRoute(
      path: '/insights',
      builder: (context, state) => const InsightsScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AsmitaBottomNav(child: child),
      routes: [
        GoRoute(path: '/home', pageBuilder: _page((_) => const HomeScreen())),
        GoRoute(
          path: '/calendar',
          pageBuilder: _page((_) => const CalendarScreen()),
        ),
        GoRoute(
          path: '/log',
          pageBuilder: _page((_) => const DailyLogScreen()),
        ),
        GoRoute(
          path: '/companion',
          pageBuilder: _page((_) => const CompanionScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: _page((_) => const ProfileScreen()),
        ),
      ],
    ),
  ],
);

Page<void> Function(BuildContext, GoRouterState) _page(
  Widget Function(GoRouterState) child,
) {
  return (context, state) => MaterialPage(child: child(state));
}
