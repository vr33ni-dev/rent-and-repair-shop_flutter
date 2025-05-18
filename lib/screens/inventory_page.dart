import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('inventory_title')),
      ),
      body: FutureBuilder<List<Surfboard>>(
        future: _boardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(localizations.translate('inventory_no_boards')),
            );
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
                      ? localizations.translate('inventory_show_only_available')
                      : localizations.translate('inventory_include_unavailable'),
                ),
                secondary: const Icon(Icons.check_circle_outline),
                value: _showOnlyAvailable,
                onChanged: (val) => setState(() => _showOnlyAvailable = val),
              ),
              SwitchListTile(
                title: Text(
                  _showOnlyShopOwned
                      ? localizations.translate('inventory_show_only_shop_owned')
                      : localizations.translate('inventory_include_customer_owned'),
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
                          Text(
                            '${localizations.translate('inventory_available')}: ${b.available ? localizations.translate('inventory_available') : localizations.translate('inventory_not_available')}',
                          ),
                          Text(
                            '${localizations.translate('inventory_damaged')}: ${b.damaged ? localizations.translate('inventory_damaged') : localizations.translate('inventory_not_damaged')}',
                          ),
                        ],
                      ),
                      trailing: b.shopOwned
                          ? Text(localizations.translate('inventory_shop_owned'))
                          : Text(localizations.translate('inventory_customer_owned')),
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