import 'package:flutter/material.dart';
import 'rentals_page.dart';
import 'repairs_page.dart';
import 'inventory_page.dart';
import 'bills_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Surf Shop Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment), text: 'Rentals'),
              Tab(icon: Icon(Icons.build), text: 'Repairs'),
              Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
              Tab(icon: Icon(Icons.money), text: 'Bills'),
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
