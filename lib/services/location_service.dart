import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RoundedLocation {
  const RoundedLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationService {
  Future<RoundedLocation> currentRoundedLocation() async {
    final permission = await Permission.locationWhenInUse.request();
    if (!permission.isGranted) throw LocationPermissionDeniedException();
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    return RoundedLocation(
      _round(position.latitude),
      _round(position.longitude),
    );
  }

  double _round(double value) => double.parse(value.toStringAsFixed(2));
}

class LocationPermissionDeniedException implements Exception {}
