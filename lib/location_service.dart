import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _i = LocationService._internal();
  factory LocationService() => _i;
  LocationService._internal();

  final _controller = StreamController<Position>.broadcast();

  Stream<Position> get stream => _controller.stream;

  Future<void> start() async {
    await Geolocator.requestPermission();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 50, // metres
      ),
    ).listen(_controller.add);
  }
}

