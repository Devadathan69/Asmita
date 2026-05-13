import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../napkin_finder_screen.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, required this.onMaps});

  final StoreResult store;
  final VoidCallback onMaps;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondary.withOpacity(.12),
                    child: Icon(
                      store.type.toLowerCase().contains('medical')
                          ? Icons.local_pharmacy_rounded
                          : Icons.storefront_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${store.type} • ${store.locality}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onMaps,
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Maps'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (store.napkinsAvailable)
                    const _InfoChip(
                      icon: Icons.check_circle_rounded,
                      label: 'Napkins available',
                      color: AppColors.success,
                    ),
                  _InfoChip(
                    icon: Icons.near_me_rounded,
                    label: '~${store.distance.round()}m away',
                    color: AppColors.primary,
                  ),
                  if (store.isApproximate)
                    const _InfoChip(
                      icon: Icons.info_outline_rounded,
                      label: 'Approximate location',
                      color: AppColors.accent,
                    ),
                ],
              ),
              if (store.note != null) ...[
                const SizedBox(height: 10),
                Text(store.note!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
