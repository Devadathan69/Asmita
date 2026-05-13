import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/build_config.dart';
import '../screens/asha/asha_camera_screen.dart';
import '../screens/asha/asha_history_screen.dart';
import '../screens/asha/asha_home_screen.dart';
import '../screens/asha/asha_instructions_screen.dart';
import '../screens/asha/asha_measurements_screen.dart';
import '../screens/asha/asha_menstrual_screen.dart';
import '../screens/asha/asha_processing_screen.dart';
import '../screens/asha/asha_result_screen.dart';
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
  redirect: (context, state) {
    final path = state.uri.path;
    if (!BuildConfig.showAshaMode && path.startsWith('/asha')) {
      return '/home';
    }
    return null;
  },
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
      redirect: (context, state) => '/asha/home',
    ),
    GoRoute(
      path: '/asha/home',
      builder: (context, state) => const AshaHomeScreen(),
    ),
    GoRoute(
      path: '/asha/instructions',
      builder: (context, state) => const AshaInstructionsScreen(),
    ),
    GoRoute(
      path: '/asha/camera/:step',
      builder: (context, state) => AshaCameraScreen(
        step: state.pathParameters['step'] ?? 'neck',
      ),
    ),
    GoRoute(
      path: '/asha/measurements',
      builder: (context, state) => const AshaMeasurementsScreen(),
    ),
    GoRoute(
      path: '/asha/menstrual',
      builder: (context, state) => const AshaMenstrualScreen(),
    ),
    GoRoute(
      path: '/asha/processing',
      builder: (context, state) => const AshaProcessingScreen(),
    ),
    GoRoute(
      path: '/asha/result',
      builder: (context, state) => const AshaResultScreen(),
    ),
    GoRoute(
      path: '/asha/history',
      builder: (context, state) => const AshaHistoryScreen(),
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
