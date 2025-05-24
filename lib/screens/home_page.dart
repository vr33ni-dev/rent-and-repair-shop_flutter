// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/screens/settings_page.dart';
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
          title: null, // no title
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.teal),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () async {
                final selectedLang = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );

                if (selectedLang != null) {
                  onLanguageChange(selectedLang);
                }
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(
                icon: Icon(Icons.assignment),
                text: loc.translate('home_rentals'),
              ),
              Tab(icon: Icon(Icons.build), text: loc.translate('home_repairs')),
              Tab(
                icon: Icon(Icons.inventory),
                text: loc.translate('home_inventory'),
              ),
              Tab(icon: Icon(Icons.money), text: loc.translate('home_bills')),
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
