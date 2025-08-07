import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'location_service.dart';
import 'data_service.dart';
import 'masjid_model.dart';
import 'geofence_service.dart';
import 'settings_page.dart';
import 'settings_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notify_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _auto = false;
  Masjid? _nearest;
  RingerModeStatus _ringer = RingerModeStatus.unknown;
  late StreamSubscription<Position> _posSub;

  @override
  void initState() {
    super.initState();
    SoundMode.ringerModeStatus.then((m) => setState(() => _ringer = m));

    LocationService().start();
    _posSub = LocationService().stream.listen(_updateNearest);
  }
void _updateNearest(Position p) async {
  _currentPos = p;

  final official = await DataService().loadOfficial();

  // ⭐️ 1.  Load custom list from prefs
  final prefs  = await SharedPreferences.getInstance();
  final customJson = prefs.getStringList(SettingsKeys.customMasjids) ?? [];
  final custom = customJson.map((s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return Masjid(
      id: m['id'],
      name: m['label'] ?? 'Custom Masjid',
      lat: m['lat'],
      lng: m['lng'],
      source: MasjidSource.custom,
    );
  }).toList();

  // ⭐️ 2.  Merge the two lists
  final all = <Masjid>[...official, ...custom];

  // ⭐️ 3.  Bail if nothing yet
  if (all.isEmpty) return;

  all.sort((a, b) => a.distanceTo(p).compareTo(b.distanceTo(p)));

  // ⭐️ 4.  Update UI
  setState(() => _nearest = all.first);
}


Future<void> _toggleAuto(bool v) async {
  setState(() => _auto = v);

  if (v) {
    await GeofenceService().arm();
    await NotifyService.show();        // show ongoing notif
  } else {
    await GeofenceService().disarm();
    await NotifyService.cancel();      // remove notif
  }
}

  Future<void> _toggleManual() async {
    final next = _ringer == RingerModeStatus.silent
        ? RingerModeStatus.normal
        : RingerModeStatus.silent;
    await SoundMode.setSoundMode(next);
    setState(() => _ringer = next);
  }

  @override
  void dispose() {
    _posSub.cancel();
    super.dispose();
  }
Position? _currentPos;

  @override
  Widget build(BuildContext context) {
  final km = (_nearest == null || _currentPos == null)
      ? '—'
      : (Geolocator.distanceBetween(
              _currentPos!.latitude,
              _currentPos!.longitude,
              _nearest!.lat,
              _nearest!.lng) /
          1000)
          .toStringAsFixed(2);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Silencer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (_) => const SettingsPage())),
          ),
        ],
      ),
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,   // vertical centre
    crossAxisAlignment: CrossAxisAlignment.center, // horizontal centre
    children: [
      // 1) logo
      Image.asset(
        'assets/logo_dark.png',
        height: 140,
      ),
      const SizedBox(height: 24),

      // 2) closest-masjid card (centred text)
      if (_nearest == null)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Locating nearest masjid…',
            textAlign: TextAlign.center,
          ),
        )
      else
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _nearest!.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '$km km away',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

      const Spacer(),                     // push toggle & button to bottom

      // 3) BIG auto-silence toggle
      Transform.scale(
        scale: 1.6,                      // enlarge switch
        child: Switch(
          value: _auto,
          onChanged: _toggleAuto,
        ),
      ),
      const SizedBox(height: 8),
      const Text('Auto-silence'),

      const SizedBox(height: 24),

      // 4) manual button
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
        onPressed: _toggleManual,
        icon: Icon(
          _ringer == RingerModeStatus.silent
              ? Icons.notifications_active
              : Icons.notifications_off,
        ),
        label: Text(
          _ringer == RingerModeStatus.silent
              ? 'Restore Sound'
              : 'Silence Test',
        ),
      ),
      const SizedBox(height: 32), // bottom padding
    ],
  ),
),

    );
  }
}
