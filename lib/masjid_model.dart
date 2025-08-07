import 'package:geolocator/geolocator.dart';

enum MasjidSource { official, custom }

class Masjid {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final MasjidSource source;

  Masjid({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.source,
  });

  double distanceTo(Position p) =>
      Geolocator.distanceBetween(lat, lng, p.latitude, p.longitude);
}
