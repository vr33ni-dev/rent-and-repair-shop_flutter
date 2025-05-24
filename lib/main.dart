import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_page.dart';

Future<void> main() async {
  // Read FLAVOR from --dart-define, defaulting to 'local'
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'local');

  // Load .env.local or .env.production or any other variant
  await dotenv.load(fileName: '.env.$flavor');

  runApp(const SurfShopApp());
}

class SurfShopApp extends StatefulWidget {
  const SurfShopApp({super.key});

  @override
  State<SurfShopApp> createState() => _SurfShopAppState();
}

class _SurfShopAppState extends State<SurfShopApp> {
  Locale _locale = const Locale('es');

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Administración',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(onLanguageChange: _changeLanguage),
    );
  }
}
