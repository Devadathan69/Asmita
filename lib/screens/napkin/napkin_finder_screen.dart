import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';
import '../../services/network_privacy_service.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/privacy_badge.dart';
import 'widgets/privacy_notice_banner.dart';
import 'widgets/store_card.dart';

class StoreResult {
  const StoreResult({
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.distance,
  });
  final String name;
  final String type;
  final double lat;
  final double lon;
  final double distance;
}

class NapkinFinderScreen extends StatefulWidget {
  const NapkinFinderScreen({super.key});
  @override
  State<NapkinFinderScreen> createState() => _NapkinFinderScreenState();
}

class _NapkinFinderScreenState extends State<NapkinFinderScreen> {
  bool accepted = false;
  bool loading = false;
  String? error;
  List<StoreResult> stores = const [];

  @override
  Widget build(BuildContext context) {
    if (!accepted) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Finding stores near you',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your location is used only to find nearby stores. It is rounded to ~1km before any request is made. It is never stored, never shared, and never used for any other purpose.',
                ),
                const SizedBox(height: 24),
                AsmitaButton(
                  label: 'Understood - Find Stores',
                  onPressed: () {
                    setState(() => accepted = true);
                    _find();
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No thanks'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Napkin Finder'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8),
            child: PrivacyBadge(label: 'Uses internet', internet: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PrivacyNoticeBanner(),
          const SizedBox(height: 12),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (error != null) Text(error!),
          if (!loading && stores.isEmpty && error == null)
            const Text('No stores found nearby. Try expanding search.'),
          for (final store in stores)
            StoreCard(
              store: store,
              onMaps: () => launchUrl(
                Uri.parse('geo:${store.lat},${store.lon}?q=sanitary+products'),
              ),
            ),
          const SizedBox(height: 12),
          AsmitaButton(label: 'Find Stores', onPressed: _find),
        ],
      ),
    );
  }

  Future<void> _find() async {
    setState(() {
      loading = true;
      error = null;
      stores = const [];
    });
    try {
      final location = await LocationService().currentRoundedLocation();
      final query =
          '[out:json];(node["shop"="chemist"](around:2000,${location.latitude},${location.longitude});node["shop"="supermarket"](around:2000,${location.latitude},${location.longitude});node["amenity"="pharmacy"](around:2000,${location.latitude},${location.longitude}););out body;';
      final body = await const NetworkPrivacyService().query(
        'https://overpass-api.de/api/interpreter',
        params: {'data': query},
      );
      final json = jsonDecode(body) as Map<String, dynamic>;
      final elements = (json['elements'] as List? ?? const []);
      stores = elements.map((e) {
        final tags = (e['tags'] as Map?) ?? {};
        final lat = (e['lat'] as num).toDouble();
        final lon = (e['lon'] as num).toDouble();
        return StoreResult(
          name: tags['name']?.toString() ?? 'Nearby store',
          type: tags['amenity']?.toString() ??
              tags['shop']?.toString() ??
              'store',
          lat: lat,
          lon: lon,
          distance: _distance(location.latitude, location.longitude, lat, lon),
        );
      }).toList()
        ..sort((a, b) => a.distance.compareTo(b.distance));
    } on LocationPermissionDeniedException {
      error =
          'Location permission denied. You can search nearby pharmacies or supermarkets in your maps app.';
    } catch (_) {
      error = 'No connection. Try again when connected.';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000;
    final p1 = lat1 * pi / 180, p2 = lat2 * pi / 180;
    final d1 = (lat2 - lat1) * pi / 180, d2 = (lon2 - lon1) * pi / 180;
    final a = sin(d1 / 2) * sin(d1 / 2) +
        cos(p1) * cos(p2) * sin(d2 / 2) * sin(d2 / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
