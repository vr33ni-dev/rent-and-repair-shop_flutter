import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';
import 'package:rent_and_repair_shop_flutter/screens/home_page.dart';
import 'env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('ENV=${Env.env}  API_URL=${Env.apiUrl}');
  assert(Env.apiUrl.isNotEmpty, 'Missing API_URL. Pass via --dart-define.');
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
      // home: DashboardPage(),
    );
  }
}
