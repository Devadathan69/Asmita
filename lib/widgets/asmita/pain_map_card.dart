import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../common/asmita_card.dart';
import 'body_pain_map_painter.dart';
import 'body_pain_map_widget.dart';

class PainMapCard extends StatefulWidget {
  const PainMapCard({
    super.key,
    required this.selectedRegions,
    required this.intensity,
    required this.onRegionsChanged,
    required this.onIntensityChanged,
    required this.noteController,
    required this.language,
    required this.isPregnant,
  });

  final Set<String> selectedRegions;
  final int intensity;
  final ValueChanged<Set<String>> onRegionsChanged;
  final ValueChanged<int> onIntensityChanged;
  final TextEditingController noteController;
  final AppLanguage language;
  final bool isPregnant;

  @override
  State<PainMapCard> createState() => _PainMapCardState();
}

class _PainMapCardState extends State<PainMapCard> {
  BodyViewSide _side = BodyViewSide.front;

  bool get _strongAbdominalPain =>
      widget.intensity >= 8 &&
      (widget.selectedRegions.contains(PainRegion.upperAbdomen.key) ||
          widget.selectedRegions.contains(PainRegion.lowerAbdomen.key) ||
          widget.selectedRegions.contains(PainRegion.lowerBack.key));

  @override
  Widget build(BuildContext context) {
    String t(String key) => Strings.t(key, widget.language);
    final warningText = _strongAbdominalPain && widget.isPregnant
        ? t('pregnancy_danger_advice')
        : widget.intensity >= 8
            ? t('strong_pain_cycle_advice')
            : null;
    final selectedText = _selectedText(t);

    return AsmitaCard(
      accent: AppColors.secondary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.coralPale,
                child: Icon(
                  Icons.accessibility_new_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('pain_map'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('tap_discomfort'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<BodyViewSide>(
            segments: [
              ButtonSegment(
                value: BodyViewSide.front,
                icon: const Icon(Icons.accessibility_new_rounded, size: 18),
                label: Text(t('front')),
              ),
              ButtonSegment(
                value: BodyViewSide.back,
                icon: const Icon(Icons.flip_to_back_rounded, size: 18),
                label: Text(t('back')),
              ),
            ],
            selected: {_side},
            showSelectedIcon: false,
            onSelectionChanged: (value) => setState(() => _side = value.first),
          ),
          const SizedBox(height: 16),
          Text(
            t('tap_one_or_more'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          BodyPainMapWidget(
            side: _side,
            selectedRegions: widget.selectedRegions,
            language: widget.language,
            onToggleRegion: _toggle,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  size: 20,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedText,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (widget.selectedRegions.isNotEmpty)
                  TextButton(
                    onPressed: () => widget.onRegionsChanged({}),
                    child: Text(t('clear_selection')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            t('pain_intensity'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _IntensityPill(
                label: t('none'),
                value: 0,
                color: AppColors.textSecondary,
                selected: widget.intensity == 0,
                onSelected: widget.onIntensityChanged,
              ),
              _IntensityPill(
                label: t('mild'),
                value: 3,
                color: AppColors.success,
                selected: widget.intensity == 3,
                onSelected: widget.onIntensityChanged,
              ),
              _IntensityPill(
                label: t('moderate'),
                value: 6,
                color: AppColors.accent,
                selected: widget.intensity == 6,
                onSelected: widget.onIntensityChanged,
              ),
              _IntensityPill(
                label: t('strong'),
                value: 9,
                color: AppColors.danger,
                selected: widget.intensity == 9,
                onSelected: widget.onIntensityChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.noteController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.edit_note_rounded),
              labelText: t('add_note_optional'),
              hintText: t('pain_note_example'),
            ),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.danger.withOpacity(.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(warningText)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggle(String region) {
    final updated = {...widget.selectedRegions};
    updated.contains(region) ? updated.remove(region) : updated.add(region);
    widget.onRegionsChanged(updated);
  }

  String _selectedText(String Function(String) t) {
    if (widget.selectedRegions.isEmpty) return t('no_area_selected');
    final ordered = [
      for (final region in PainRegion.values)
        if (widget.selectedRegions.contains(region.key))
          Strings.t(region.labelKey, widget.language),
    ];
    return '${t('selected')}: ${ordered.join(', ')}';
  }
}

class _IntensityPill extends StatelessWidget {
  const _IntensityPill({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int value;
  final Color color;
  final bool selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, softWrap: false),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: color.withOpacity(.18),
      backgroundColor: color.withOpacity(.07),
      side: BorderSide(color: selected ? color : color.withOpacity(.22)),
      labelStyle: TextStyle(
        color: selected ? color : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w900,
      ),
      onSelected: (_) => onSelected(value),
    );
  }
}
