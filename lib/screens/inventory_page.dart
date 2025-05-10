import 'package:flutter/material.dart';
import '../models/surfboard.dart';
import '../services/api_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Future<List<Surfboard>> _boards;

  @override
  void initState() {
    super.initState();
    _boards = ApiService().fetchSurfboards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surfboard Inventory')),
      body: FutureBuilder<List<Surfboard>>(
        future: _boards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No surfboards found.'));
          }

          final boards = snapshot.data!;
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final b = boards[index];
              return ListTile(
                title: Text(b.name),
                subtitle: Text(
                  'Available: ${b.available ? 'Yes' : 'No'} | Damaged: ${b.damaged ? 'Yes' : 'No'}',
                ),
                trailing:
                    b.shopOwned
                        ? const Text('🛒 Shop-owned')
                        : const Text('👤 Customer-owned'),
              );
            },
          );
        },
      ),
    );
  }
}
