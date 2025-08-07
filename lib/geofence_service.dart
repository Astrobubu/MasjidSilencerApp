import 'dart:convert';
import 'geofence_handler.dart';
import 'settings_keys.dart'; // keys reused below
import 'package:geofencing_api/geofencing_api.dart';           // ← single clean import
import 'package:shared_preferences/shared_preferences.dart';   // ← NEW
import 'data_service.dart';          // ← NEW
import 'masjid_model.dart';          // ← NEW

class GeofenceService {
  static final GeofenceService _i = GeofenceService._internal();
  factory GeofenceService() => _i;
  GeofenceService._internal();

  Future<void> arm() async {
    final prefs   = await SharedPreferences.getInstance();
    final stored  = prefs.getStringList(SettingsKeys.customMasjids) ?? [];
    final radius  = prefs.getDouble(SettingsKeys.radius) ?? 150.0;

    /* 1️⃣  build regions from custom list */
    final customRegions = stored.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return GeofenceRegion.circular(
        id: 'c_${m['id']}',
        center: LatLng(
          (m['lat'] as num).toDouble(),          // ← ensure double
          (m['lng'] as num).toDouble(),          // ← ensure double
        ),
        radius: radius,
        loiteringDelay: 0,
      );
    });

    /* 2️⃣  build regions from OFFICIAL CSV */
    final official = await DataService().loadOfficial();      // parse CSV
    // NOTE: Android caps each app at 100 geofences ⇒ keep the first 80
    final officialRegions = official.take(80).map((Masjid m) {
      return GeofenceRegion.circular(
        id: 'o_${m.id}',
        center: LatLng(m.lat, m.lng),
        radius: radius,
        loiteringDelay: 0,
      );
    });

    /* 3️⃣  merge & register */
    final regions = {...customRegions, ...officialRegions}.toSet();
    print('📍  Arm geofence: custom=${customRegions.length} '
      'official=${officialRegions.length} total=${regions.length}');

    if (regions.isEmpty) return; // nothing to arm

    Geofencing.instance
      ..removeGeofenceStatusChangedListener(geofenceCallback)
      ..addGeofenceStatusChangedListener(geofenceCallback);

    try {
      await Geofencing.instance.start(regions: regions);
      print('🚀 Geofencing ARMED');
    } catch (e) {
      print('❌ Geofencing start failed: $e');
    }
  }

  Future<void> disarm() async => Geofencing.instance.stop();
}
