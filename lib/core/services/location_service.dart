import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

enum LocationStatus {
  success,
  servicesDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  error,
}

class LocationResult {
  const LocationResult({required this.status, this.position});
  final LocationStatus status;
  final Position? position;

  bool get isSuccess => status == LocationStatus.success && position != null;
}

class LocationService {
  static const String _latitudeKey = 'cached_latitude';
  static const String _longitudeKey = 'cached_longitude';
  static const String _locationNameKey = 'cached_location_name';

  /// Request location permission only (shows OS dialog) without needing services enabled.
  /// Returns the resulting permission status.
  Future<LocationPermission> requestPermissionOnly() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (e) {
      AppLogger.error('Error requesting location permission', error: e);
      return LocationPermission.denied;
    }
  }

  /// Gets the current position with detailed status — does NOT show any UI.
  Future<LocationResult> getCurrentPositionWithStatus() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(status: LocationStatus.permissionDenied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationStatus.permissionPermanentlyDenied,
        );
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(status: LocationStatus.servicesDisabled);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await _cacheLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      return LocationResult(status: LocationStatus.success, position: position);
    } catch (e) {
      AppLogger.error('Error getting location', error: e);
      return const LocationResult(status: LocationStatus.error);
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.error('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.error('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.error(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      await _cacheLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      return position;
    } catch (e) {
      AppLogger.error('Error getting location', error: e);
      return null;
    }
  }

  Future<String?> getLocationName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name =
            "${place.locality ?? ''}, ${place.administrativeArea ?? ''}"
                .trim()
                .replaceAll(RegExp(r'^,\s*|\s*,\s*$'), '');
        if (name.isNotEmpty) {
          final cached = await getCachedLocation();
          await _cacheLocation(
            latitude: lat,
            longitude: lng,
            locationName: name,
            fallbackName: cached?.locationName,
          );
        }
        return name;
      }
    } catch (e) {
      AppLogger.error('Error getting location name', error: e);
    }
    return null;
  }

  Future<CachedLocation?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latitudeKey);
      final lng = prefs.getDouble(_longitudeKey);
      final locationName = prefs.getString(_locationNameKey) ?? '';
      if (lat == null || lng == null) {
        return null;
      }
      return CachedLocation(
        latitude: lat,
        longitude: lng,
        locationName: locationName.trim().isEmpty ? null : locationName.trim(),
      );
    } catch (e) {
      AppLogger.error('Error reading cached location', error: e);
      return null;
    }
  }

  Future<CachedLocation?> getBestAvailableLocation() async {
    final position = await getCurrentPosition();
    if (position != null) {
      String? locationName = await getLocationName(
        position.latitude,
        position.longitude,
      );
      locationName = locationName?.trim();
      final resolved = CachedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName?.isEmpty ?? true ? null : locationName,
      );
      await _cacheLocation(
        latitude: resolved.latitude,
        longitude: resolved.longitude,
        locationName: resolved.locationName,
      );
      return resolved;
    }
    return getCachedLocation();
  }

  Future<void> _cacheLocation({
    required double latitude,
    required double longitude,
    String? locationName,
    String? fallbackName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latitudeKey, latitude);
      await prefs.setDouble(_longitudeKey, longitude);
      final name = (locationName ?? fallbackName ?? '').trim();
      if (name.isNotEmpty) {
        await prefs.setString(_locationNameKey, name);
      }
    } catch (e) {
      AppLogger.error('Error caching location', error: e);
    }
  }
}

class CachedLocation {
  const CachedLocation({
    required this.latitude,
    required this.longitude,
    this.locationName,
  });

  final double latitude;
  final double longitude;
  final String? locationName;
}
