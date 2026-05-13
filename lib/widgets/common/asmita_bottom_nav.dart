import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/personal_tracking_mode_provider.dart';
import '../../theme/app_colors.dart';

class AsmitaBottomNav extends ConsumerWidget {
  const AsmitaBottomNav({super.key, required this.child});
  final Widget child;

  static const routes = [
    '/home',
    '/calendar',
    '/log',
    '/companion',
    '/profile',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final index = routes
        .indexWhere((r) => location.startsWith(r))
        .clamp(0, routes.length - 1);
    final language = ref.watch(languageProvider).value ?? AppLanguage.english;
    final mode = ref.watch(personalTrackingModeProvider);
    String t(String key) => Strings.t(key, language);
    final items = [
      _NavItem(Icons.home_rounded, t('home')),
      _NavItem(Icons.calendar_month_rounded, t('calendar')),
      _NavItem(Icons.add_chart_rounded, t('log')),
      _NavItem(
        mode == PersonalTrackingMode.pregnancy
            ? Icons.favorite_rounded
            : Icons.auto_awesome_rounded,
        mode == PersonalTrackingMode.pregnancy ? t('care') : t('companion'),
      ),
      _NavItem(Icons.person_rounded, t('more')),
    ];
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(.96),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.12),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == index,
                    onTap: () => context.go(routes[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.navInactive;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPale : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: selected ? 25 : 23)
                .animate(target: selected ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.12, 1.12),
                  duration: 220.ms,
                ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
