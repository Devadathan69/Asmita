import 'package:flutter/material.dart';
import '../../../widgets/common/asmita_card.dart';

class DataExportWidget extends StatelessWidget {
  const DataExportWidget({super.key});
  @override
  Widget build(BuildContext context) => const AsmitaCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.lock_outline),
          title: Text('Encrypted export'),
          subtitle:
              Text('This file contains your health data. Keep it private.'),
        ),
      );
}
