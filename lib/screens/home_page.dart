// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'rentals_page.dart';
import 'repairs_page.dart';
import 'inventory_page.dart';
import 'bills_page.dart';

class HomePage extends StatelessWidget {
  final Function(String) onLanguageChange;

  const HomePage({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('title')),
          actions: [
            DropdownButton<String>(
              value: Localizations.localeOf(context).languageCode,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: Colors.teal,
              onChanged: (lang) => lang != null ? onLanguageChange(lang) : null,
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.assignment),
                text: loc.translate('home_rentals'),
              ),
              Tab(
                icon: const Icon(Icons.build),
                text: loc.translate('home_repairs'),
              ),
              Tab(
                icon: const Icon(Icons.inventory),
                text: loc.translate('home_inventory'),
              ),
              Tab(
                icon: const Icon(Icons.money),
                text: loc.translate('home_bills'),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: const TabBarView(
            children: [
              RentalsPage(),
              RepairsPage(),
              InventoryPage(),
              BillsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
