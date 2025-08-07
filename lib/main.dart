import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_page.dart';
import "notify_service.dart";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifyService.init();          // NEW
  runApp(const MasjidSilencerApp());
}

class MasjidSilencerApp extends StatelessWidget {
  const MasjidSilencerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Masjid Silencer',
        theme: AppTheme.dark(),
        home: const HomePage(),
      );
}
