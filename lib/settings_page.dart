import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:csv/csv.dart';           // NEW

import 'settings_keys.dart';
import 'data_service.dart';
import 'masjid_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dbReady = false;
  int  _count   = 0;

  /// custom list
  List<Map<String, dynamic>> _custom = [];
  final _latCtl   = TextEditingController();
  final _lngCtl   = TextEditingController();
  final _labelCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // official DB status
    final csv = prefs.getString(SettingsKeys.officialCsv);
    _dbReady  = csv != null;
    _count    = csv == null ? 0 : CsvToListConverter().convert(csv).length - 1;

    // custom list
    final stored = prefs.getStringList(SettingsKeys.customMasjids) ?? [];
    _custom = stored.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

    setState(() {});
  }

  Future<void> _saveCustom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        SettingsKeys.customMasjids, _custom.map(jsonEncode).toList());
  }

  /* ────── UI helpers ───── */

  Future<void> _updateOfficial() async {
    try {
      await DataService().refreshOfficial();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masjid database updated')),
        );
      }
      _load(); // refresh counters
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  void _addCustom() {
    final lat = double.tryParse(_latCtl.text);
    final lng = double.tryParse(_lngCtl.text);
    if (lat == null || lng == null) return;

    setState(() {
      _custom.add({
        'id'   : DateTime.now().millisecondsSinceEpoch.toString(),
        'lat'  : lat,
        'lng'  : lng,
        'label': _labelCtl.text.isEmpty ? 'Custom Masjid' : _labelCtl.text,
      });
    });
    _latCtl.clear();
    _lngCtl.clear();
    _labelCtl.clear();
    _saveCustom();
  }

  Future<void> _shareByMail(Map<String, dynamic> m) async {
    final subject = Uri.encodeComponent('New Masjid Location');
    final body = Uri.encodeComponent(
        'Label: ${m['label']}\nLat: ${m['lat']}\nLng: ${m['lng']}');
    final uri = Uri.parse(
        'mailto:Akhmad6093@gmail.com?subject=$subject&body=$body');
    await launchUrl(uri);
  }

  Future<void> _testSilence() async {
    await SoundMode.setSoundMode(RingerModeStatus.silent);
    await Future.delayed(const Duration(seconds: 2));
    await SoundMode.setSoundMode(RingerModeStatus.normal);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /* ---------- OFFICIAL db ---------- */
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dbReady
                        ? 'Official DB: $_count masjids'
                        : 'Official DB: not downloaded',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ElevatedButton(
                  onPressed: _updateOfficial,
                  child: const Text('Update'),
                ),
              ],
            ),
            const Divider(height: 32),

            /* ---------- CUSTOM list ---------- */
            Text('My Custom Locations',
                style: Theme.of(context).textTheme.titleMedium),
            ..._custom.map((m) => ListTile(
                  title: Text(m['label']),
                  subtitle: Text('${m['lat']}, ${m['lng']}'),
                  leading: const Icon(Icons.place),
                  trailing: IconButton(
                    icon: const Icon(Icons.mail),
                    onPressed: () => _shareByMail(m),
                  ),
                  onLongPress: () => setState(() {
                    _custom.remove(m);
                    _saveCustom();
                  }),
                )),

            const SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _labelCtl,
                    decoration:
                        const InputDecoration(labelText: 'Label', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    controller: _latCtl,
                    decoration:
                        const InputDecoration(labelText: 'Lat', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    controller: _lngCtl,
                    decoration:
                        const InputDecoration(labelText: 'Lng', isDense: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addCustom),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testSilence,
              child: const Text('Test Silence (2 s)'),
            ),
          ],
        ),
      );
}
