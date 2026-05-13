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
    this.locality = 'Kothamangalam, Kerala',
    this.napkinsAvailable = true,
    this.isApproximate = false,
    this.note,
  });
  final String name;
  final String type;
  final double lat;
  final double lon;
  final double distance;
  final String locality;
  final bool napkinsAvailable;
  final bool isApproximate;
  final String? note;
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
  String? info;
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
          if (info != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city_rounded),
                title: Text(info!),
              ),
            ),
            const SizedBox(height: 8),
          ],
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
      info = null;
      stores = const [];
    });
    try {
      final location = await LocationService().currentRoundedLocation();
      final localStores = _localKothamangalamStores(
        userLat: location.latitude,
        userLon: location.longitude,
      );
      final query =
          '[out:json];(node["shop"="chemist"](around:2000,${location.latitude},${location.longitude});node["shop"="supermarket"](around:2000,${location.latitude},${location.longitude});node["amenity"="pharmacy"](around:2000,${location.latitude},${location.longitude}););out body;';
      final body = await const NetworkPrivacyService().query(
        'https://overpass-api.de/api/interpreter',
        params: {'data': query},
      );
      final json = jsonDecode(body) as Map<String, dynamic>;
      final elements = (json['elements'] as List? ?? const []);
      final osmStores = elements.map((e) {
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
          locality: 'Nearby',
          napkinsAvailable: false,
        );
      }).toList();
      stores = [...localStores, ...osmStores]
        ..sort((a, b) => a.distance.compareTo(b.distance));
    } on LocationPermissionDeniedException {
      stores = _localKothamangalamStores();
      info = 'Stores in Kothamangalam';
      error =
          'Location permission denied. Showing verified local stores without using your location.';
    } catch (_) {
      stores = _localKothamangalamStores();
      info = 'Stores in Kothamangalam';
      error = 'No connection. Showing verified local stores saved in the app.';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<StoreResult> _localKothamangalamStores({
    double? userLat,
    double? userLon,
  }) {
    const fallbackLat = 10.0649;
    const fallbackLon = 76.6283;
    final originLat = userLat ?? fallbackLat;
    final originLon = userLon ?? fallbackLon;
    const note =
        'Approximate location - please confirm in maps or with the store before visiting.';
    final stores = [
      (
        name: 'Jas Medicals',
        type: 'Medical store',
        lat: 10.0649,
        lon: 76.6283,
      ),
      (
        name: 'Smitha Medicals',
        type: 'Medical store',
        lat: 10.0660,
        lon: 76.6292,
      ),
      (
        name: 'Easy Bazar',
        type: 'Store',
        lat: 10.0638,
        lon: 76.6274,
      ),
      (
        name: 'Samrudhi Store',
        type: 'Store',
        lat: 10.0656,
        lon: 76.6267,
      ),
    ];
    return stores.map((store) {
      return StoreResult(
        name: store.name,
        type: store.type,
        lat: store.lat,
        lon: store.lon,
        distance: _distance(originLat, originLon, store.lat, store.lon),
        locality: 'Kothamangalam, Kerala',
        napkinsAvailable: true,
        isApproximate: true,
        note: note,
      );
    }).toList();
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
