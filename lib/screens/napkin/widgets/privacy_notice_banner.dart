import 'package:flutter/material.dart';

class PrivacyNoticeBanner extends StatelessWidget {
  const PrivacyNoticeBanner({super.key});
  @override
  Widget build(BuildContext context) => const Card(
        child: ListTile(
          leading: Icon(Icons.lock_outline),
          title:
              Text('Location not stored • Rounded to 1km • OpenStreetMap only'),
        ),
      );
}
