import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/app_logger.dart';

class LocationService {
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
            'Location permissions are permanently denied, we cannot request permissions.');
        return null;
      }

      return await Geolocator.getCurrentPosition();
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
        return "${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      }
    } catch (e) {
      AppLogger.error('Error getting location name', error: e);
    }
    return null;
  }
}
