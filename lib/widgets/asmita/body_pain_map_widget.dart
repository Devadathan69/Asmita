import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import 'body_pain_map_painter.dart';

class BodyPainMapWidget extends StatelessWidget {
  const BodyPainMapWidget({
    super.key,
    required this.side,
    required this.selectedRegions,
    required this.onToggleRegion,
    required this.language,
  });

  final BodyViewSide side;
  final Set<String> selectedRegions;
  final ValueChanged<String> onToggleRegion;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: AspectRatio(
          aspectRatio: .72,
          child: RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: BodyPainMapPainter(
                        side: side,
                        selectedRegions: selectedRegions,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                      ),
                    ),
                    for (final region in PainRegion.valuesFor(side))
                      _RegionTapTarget(
                        region: region,
                        rect: BodyPainMapLayout.regionRect(region, side, size),
                        selected: selectedRegions.contains(region.key),
                        label: Strings.t(region.labelKey, language),
                        onTap: () => onToggleRegion(region.key),
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
}

class _RegionTapTarget extends StatelessWidget {
  const _RegionTapTarget({
    required this.region,
    required this.rect,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final PainRegion region;
  final Rect rect;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect.inflate(7),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onTap,
              splashColor: AppColors.secondary.withOpacity(.12),
              highlightColor: AppColors.secondary.withOpacity(.08),
            ),
          ),
        ),
      ),
    );
  }
}
