import 'package:geofencing_api/geofencing_api.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:sound_mode/permission_handler.dart' as sm;   // DND helper

/// Runs even if the app is killed; prints every enter/exit.
@pragma('vm:entry-point')
Future<void> geofenceCallback(
  GeofenceRegion region,
  GeofenceStatus status,
  Location loc,
) async {
  final ts = DateTime.now().toIso8601String();
  print('[$ts] 🔔 geofenceCallback  ${region.id}  •  $status '
        '@ ${loc.latitude},${loc.longitude}');

  Future<void> _set(RingerModeStatus mode) async {
    final granted = await sm.PermissionHandler.permissionsGranted;
    print('[$ts]    DND granted = $granted');
    try {
      await SoundMode.setSoundMode(mode);
    } catch (e) {
      print('[$ts]    ❌ setSoundMode FAILED: $e');
    }
    final after = await SoundMode.ringerModeStatus;
    print('[$ts]    ➡️  ringer AFTER = $after');
  }

  if (status == GeofenceStatus.enter) {
    await _set(RingerModeStatus.silent);
  } else if (status == GeofenceStatus.exit) {
    await _set(RingerModeStatus.normal);
  }
}
