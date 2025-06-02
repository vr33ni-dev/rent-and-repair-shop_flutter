// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/screens/dashboard_overview_widget.dart';
import 'package:rent_and_repair_shop_flutter/screens/overdue_returns.dart';
import 'package:rent_and_repair_shop_flutter/screens/recent_activity_widget.dart';
import 'inventory_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DashboardOverview(),
              SizedBox(height: 24),
              RecentActivityCard(),
              SizedBox(height: 16),
              OverdueReturnsCard(),
              SizedBox(height: 32),
              //   // Re-use your existing pages as widgets:
              Text(
                'Inventory Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.teal),
                  title: const Text(
                    'Inventory Management',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InventoryPage()),
                    );
                  },
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Bills & Invoices',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              //   BillsPage(),
              SizedBox(height: 32),
              Text(
                'Rentals Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              //   RentalsPage(),
              SizedBox(height: 32),
              Text(
                'Repairs Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              //   RepairsPage(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
