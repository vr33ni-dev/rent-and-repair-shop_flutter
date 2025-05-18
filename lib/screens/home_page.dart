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
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('title')),
          actions: [
            DropdownButton<String>(
              value: Localizations.localeOf(context).languageCode,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: Colors.teal,
              onChanged: (String? languageCode) {
                if (languageCode != null) {
                  onLanguageChange(languageCode);
                }
              },
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
                text: localizations.translate('home_rentals'),
              ),
              Tab(
                icon: const Icon(Icons.build),
                text: localizations.translate('home_repairs'),
              ),
              Tab(
                icon: const Icon(Icons.inventory),
                text: localizations.translate('home_inventory'),
              ),
              Tab(
                icon: const Icon(Icons.money),
                text: localizations.translate('home_bills'),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RentalsPage(),
            RepairsPage(),
            InventoryPage(),
            BillsPage(),
          ],
        ),
      ),
    );
  }
}
