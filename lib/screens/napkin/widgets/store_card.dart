import 'package:flutter/material.dart';
import '../napkin_finder_screen.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, required this.onMaps});
  final StoreResult store;
  final VoidCallback onMaps;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(store.name),
          subtitle: Text('${store.type} • ~${store.distance.round()}m away'),
          trailing: TextButton(onPressed: onMaps, child: const Text('Maps')),
        ),
      );
}
