// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/screens/dashboard_overview_widget.dart';
import 'package:rent_and_repair_shop_flutter/screens/recent_activity_widget.dart';
import 'package:rent_and_repair_shop_flutter/screens/settings_page.dart';
import 'package:rent_and_repair_shop_flutter/screens/rentals_page.dart';
import 'package:rent_and_repair_shop_flutter/screens/repairs_page.dart';
import 'package:rent_and_repair_shop_flutter/screens/inventory_page.dart';
import 'package:rent_and_repair_shop_flutter/screens/bills_page.dart';

import '../l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  final Function(String) onLanguageChange;

  const HomePage({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return DefaultTabController(
      length: 5, // ← now 5 tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.teal),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: loc.translate('settings'),
              onPressed: () async {
                final selectedLang = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
                if (selectedLang != null) onLanguageChange(selectedLang);
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
                icon: const Icon(Icons.dashboard),
                text: loc.translate('home_overview'),
              ), // new
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
          child: TabBarView(
            children: [
              // ─── Dashboard “Overview” Tab ───────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardOverview(),
                    const SizedBox(height: 24),
                    const RecentActivityCard(),
                    const SizedBox(height: 16),
                    // const OverdueReturnsCard(),
                  ],
                ),
              ),

              // ─── Your existing pages ─────────────────────────
              const RentalsPage(),
              const RepairsPage(),
              const InventoryPage(),
              const BillsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
