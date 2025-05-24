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

  // ── filter state ─────────────────────────────────────
  bool _showOnlyAvailable = true;
  bool _showOnlyShopOwned = true;
  String _searchTerm = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  void _loadBoards() {
    setState(() {
      _boardsFuture = ApiService().fetchSurfboards();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddBoardDialog() async {
    final formKey = GlobalKey<FormState>();
    String? name, description, sizeText, issue;
    bool damaged = false;
    final local = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setSt) => AlertDialog(
                  title: Text(local.translate('inventory_add_board')),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: local.translate(
                                'inventory_board_name',
                              ),
                            ),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? local.translate(
                                          'inventory_field_required',
                                        )
                                        : null,
                            onSaved: (v) => name = v?.trim(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: local.translate(
                                'inventory_description',
                              ),
                            ),
                            onSaved: (v) => description = v?.trim(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: local.translate('inventory_size'),
                            ),
                            onSaved: (v) => sizeText = v?.trim(),
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            title: Text(local.translate('inventory_damaged')),
                            value: damaged,
                            onChanged: (v) => setSt(() => damaged = v!),
                          ),
                          if (damaged)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: local.translate(
                                  'inventory_damage_issue',
                                ),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? local.translate(
                                            'inventory_field_required',
                                          )
                                          : null,
                              onSaved: (v) => issue = v,
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(local.translate('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          final ok = await ApiService().createSurfboard(
                            name: name!,
                            description: description ?? '',
                            sizeText: sizeText,
                            damaged: damaged,
                            issue: issue ?? '',
                          );
                          Navigator.of(ctx).pop();
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  local.translate('inventory_board_added'),
                                ),
                              ),
                            );
                            _loadBoards();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  local.translate('inventory_error_adding'),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(local.translate('inventory_add')),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      // appBar: AppBar(title: Text(local.translate('inventory_title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBoardDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Surfboard>>(
        future: _boardsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('❌ ${snap.error}'));

          // 1) start with all
          var boards = snap.data ?? [];

          // 2) apply search filter
          if (_searchTerm.isNotEmpty) {
            final term = _searchTerm.toLowerCase();
            boards =
                boards.where((b) {
                  return b.name.toLowerCase().contains(term) ||
                      (b.description?.toLowerCase().contains(term) ?? false);
                }).toList();
          }

          // 3) apply availability/shop‐owned filters
          if (_showOnlyAvailable) {
            boards = boards.where((b) => b.available).toList();
          }
          if (_showOnlyShopOwned) {
            boards = boards.where((b) => b.shopOwned).toList();
          }

          return Column(
            children: [
              // ─── Collapsible Filter Panel ───────────────────
              Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                  child: ExpansionTile(
                    title: Text(
                      local.translate('inventory_filters_title'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(vertical: 4),
                    children: [
                      // your filters: switches & search box here
                      // Only‐available switch
                      SwitchListTile(
                        title: Text(
                          _showOnlyAvailable
                              ? local.translate('inventory_show_only_available')
                              : local.translate(
                                'inventory_include_unavailable',
                              ),
                        ),
                        secondary: const Icon(Icons.check_circle_outline),
                        value: _showOnlyAvailable,
                        onChanged:
                            (v) => setState(() => _showOnlyAvailable = v),
                      ),

                      // Shop‐owned switch
                      SwitchListTile(
                        title: Text(
                          _showOnlyShopOwned
                              ? local.translate(
                                'inventory_show_only_shop_owned',
                              )
                              : local.translate(
                                'inventory_include_customer_owned',
                              ),
                        ),
                        secondary: const Icon(Icons.storefront),
                        value: _showOnlyShopOwned,
                        onChanged:
                            (v) => setState(() => _showOnlyShopOwned = v),
                      ),
                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: local.translate('inventory_search'),
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged:
                              (v) => setState(() => _searchTerm = v.trim()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Boards List ────────────────────────────────
              Expanded(
                child:
                    boards.isEmpty
                        ? Center(
                          child: Text(
                            local.translate('inventory_no_boards_found'),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: boards.length,

                          itemBuilder: (ctx, i) {
                            final b = boards[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header row
                                    Row(
                                      children: [
                                        CircleAvatar(child: Text('${i + 1}')),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            b.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Description and info
                                    Text(
                                      '${local.translate('inventory_description')}: '
                                      '${b.description?.isNotEmpty == true ? b.description : '-'}',
                                    ),
                                    Text(
                                      '${local.translate('inventory_available')}: '
                                      '${b.available ? local.translate('inventory_available') : local.translate('inventory_not_available')}',
                                    ),
                                    Text(
                                      '${local.translate('inventory_damaged')}: '
                                      '${b.damaged ? local.translate('inventory_damaged') : local.translate('inventory_not_damaged')}',
                                    ),

                                    const SizedBox(height: 12),

                                    // Bottom right alignment for ownership info
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        b.shopOwned
                                            ? local.translate(
                                              'inventory_shop_owned',
                                            )
                                            : local.translate(
                                              'inventory_customer_owned',
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
