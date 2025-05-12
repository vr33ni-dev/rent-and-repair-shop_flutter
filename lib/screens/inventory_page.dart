import 'package:flutter/material.dart';
import '../models/surfboard.dart';
import '../services/api_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Future<List<Surfboard>> _boardsFuture;
  bool _showOnlyAvailable = true;
  bool _showOnlyShopOwned = true;

  @override
  void initState() {
    super.initState();
    _boardsFuture = ApiService().fetchSurfboards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surfboard Inventory')),
      body: FutureBuilder<List<Surfboard>>(
        future: _boardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No surfboards found.'));
          }

          final allBoards = snapshot.data!;
          var boards = allBoards;
          if (_showOnlyAvailable) {
            boards = boards.where((b) => b.available).toList();
          }
          if (_showOnlyShopOwned) {
            boards = boards.where((b) => b.shopOwned).toList();
          }

          return Column(
            children: [
              SwitchListTile(
                title: Text(
                  _showOnlyAvailable
                      ? 'Showing only available'
                      : 'Including unavailable',
                ),
                secondary: const Icon(Icons.check_circle_outline),
                value: _showOnlyAvailable,
                onChanged: (val) => setState(() => _showOnlyAvailable = val),
              ),
              SwitchListTile(
                title: Text(
                  _showOnlyShopOwned
                      ? 'Showing only shop-owned'
                      : 'Including customer-owned',
                ),
                secondary: const Icon(Icons.storefront),
                value: _showOnlyShopOwned,
                onChanged: (val) => setState(() => _showOnlyShopOwned = val),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final b = boards[index];
                    return ListTile(
                      title: Text(
                        '${b.name} (ID: ${b.id})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (b.shopOwned)
                            Text('Available: ${b.available ? 'Yes' : 'No'}'),
                          Text('Damaged: ${b.damaged ? 'Yes' : 'No'}'),
                        ],
                      ),
                      trailing:
                          b.shopOwned
                              ? const Text('🛒 Shop-owned')
                              : const Text('👤 Customer-owned'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
