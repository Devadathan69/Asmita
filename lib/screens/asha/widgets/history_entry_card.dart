import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../db/models/screening_record.dart';
import 'risk_score_card.dart';

class HistoryEntryCard extends StatelessWidget {
  const HistoryEntryCard({super.key, required this.record});

  final ScreeningRecord record;

  @override
  Widget build(BuildContext context) {
    final color = RiskScoreCard.tierColor(record.color);
    return Card(
      child: ExpansionTile(
        title:
            Text(DateFormat('dd MMM yyyy, h:mm a').format(record.screenedAt)),
        subtitle: Text('${record.topMarker()} • ${record.scoreLabel}'),
        trailing: Chip(
          label: Text(record.riskTier),
          backgroundColor: color.withOpacity(.16),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        children: [
          for (final item in record.breakdown.entries)
            ListTile(
              dense: true,
              title: Text(item.key),
              trailing: Text(item.value.toStringAsFixed(1)),
            ),
        ],
      ),
    );
  }
}

extension on ScreeningRecord {
  String get scoreLabel => '$riskScore/85';
}
