import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'masjid_model.dart';

class DataService {
  static final DataService _i = DataService._internal();
  factory DataService() => _i;
  DataService._internal();

  static const _prefsKeyCsv   = 'official_csv';
  static const _prefsKeyTime  = 'official_csv_time';
  static const _defaultCsvUrl =
      'https://raw.githubusercontent.com/Astrobubu/MasjidSilencerApp/refs/heads/main/uae_mosques.csv';

Future<List<Masjid>> loadOfficial() async {
  final prefs = await SharedPreferences.getInstance();
  var csvStr  = prefs.getString(_prefsKeyCsv);

  csvStr ??= await _downloadCsv(_defaultCsvUrl); // first run

  final rows = const CsvToListConverter().convert(csvStr);

  // ─── figure out column indexes from header row ───
final header = rows.first
    .map((e) => e.toString().toLowerCase().trim())
    .toList();

int _idx(List<String> keys) =>
    header.indexWhere((h) => keys.contains(h));

final nameIx = _idx(['name', 'mosque_name', 'title']);
final latIx  = _idx(['lat', 'latitude']);
final lngIx  = _idx(['lng', 'lon', 'long', 'longitude']);
final idIx   = _idx(['id', 'uid']);

if (nameIx < 0 || latIx < 0 || lngIx < 0) {
  throw Exception(
      'CSV header must contain name/lat/lng columns (found: $header)');
}

  if (nameIx < 0 || latIx < 0 || lngIx < 0) {
    throw Exception('CSV must contain name,lat,lng columns');
  }

  final out = <Masjid>[];
  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    if (r.length <= lngIx) continue;             // skip bad row
    final lat = double.tryParse(r[latIx].toString());
    final lng = double.tryParse(r[lngIx].toString());
    if (lat == null || lng == null) continue;    // skip bad coords
    out.add(Masjid(
      id   : idIx >= 0 && r.length > idIx && r[idIx].toString().isNotEmpty
             ? r[idIx].toString()
             : 'row_$i',
      name : r[nameIx].toString(),
      lat  : lat,
      lng  : lng,
      source: MasjidSource.official,
    ));
  }
  return out;
}


  Future<void> refreshOfficial([String? url]) async {
    final csv = await _downloadCsv(url ?? _defaultCsvUrl);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyCsv, csv);
    await prefs.setInt(_prefsKeyTime, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String> _downloadCsv(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) return res.body;
    throw Exception('CSV download failed');
  }
}
