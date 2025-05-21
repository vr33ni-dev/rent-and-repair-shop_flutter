import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';
import '../models/repair_response.dart';
import '../services/api_service.dart';
import '../enums/repair_status.dart';

enum _SortOrder { newestFirst, oldestFirst }

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  late Future<List<RepairResponse>> _repairs;
  bool _showAll = false;
  _SortOrder _sortOrder = _SortOrder.newestFirst;
  DateTimeRange? _filterRange;
  String _searchTerm = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  void _loadRepairs() {
    setState(() {
      _repairs = ApiService().fetchRepairs();
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final lastYear = DateTime(now.year - 1, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: lastYear,
      lastDate: now,
      initialDateRange: _filterRange,
    );
    if (picked != null) setState(() => _filterRange = picked);
  }

  void _clearDateRange() {
    setState(() => _filterRange = null);
  }

  Future<void> _markAsRepaired(String id) async {
    final loc = AppLocalizations.of(context);
    try {
      await ApiService().markRepairAsCompleted(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('repairs_marked_as_completed'))),
      );
      _loadRepairs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('repairs_error')}: $e')),
      );
    }
  }

  Future<void> _cancelRepair(String id) async {
    final loc = AppLocalizations.of(context);
    try {
      final ok = await ApiService().cancelRepair(id);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('repairs_canceled'))),
        );
        _loadRepairs();
      } else {
        throw Exception('Cancel failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('repairs_error')}: $e')),
      );
    }
  }

  void _showCreateRepairDialog() {
    final formKey = GlobalKey<FormState>();
    String? customerName, customerContact, surfboardName, issue, feeText;
    final loc = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(loc.translate('repairs_new_repair')),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.translate('repairs_customer_name'),
                      ),
                      onSaved: (v) => customerName = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? loc.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.translate('repairs_customer_contact'),
                      ),
                      onSaved: (v) => customerContact = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? loc.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.translate('repairs_board'),
                      ),
                      onSaved: (v) => surfboardName = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? loc.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.translate('repairs_issue'),
                      ),
                      onSaved: (v) => issue = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? loc.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.translate('repairs_fee'),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => feeText = v,
                      validator:
                          (v) =>
                              v == null || double.tryParse(v) == null
                                  ? loc.translate('invalid_number')
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(loc.translate('cancel')),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: Text(loc.translate('repairs_create')),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final fee = double.parse(feeText!);
                    final ok = await ApiService().createRepair(
                      customerName: customerName!,
                      customerContact: customerContact!,
                      surfboardName: surfboardName!,
                      issue: issue!,
                      repairFee: fee,
                    );
                    Navigator.of(ctx).pop();
                    if (ok) _loadRepairs();
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      // appBar: AppBar(title: Text(loc.translate('repairs_title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRepairDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ─── collapsible filter panel ───────────────────────
          ExpansionTile(
            title: Text(
              loc.translate('repairs_filters_title'),
            ), // e.g. “Filters & Sort”
            childrenPadding: const EdgeInsets.symmetric(vertical: 4),
            children: [
              // Date‐range row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _filterRange == null
                            ? loc.translate('repairs_filter_by_date')
                            : '${dateFormat.format(_filterRange!.start)} → ${dateFormat.format(_filterRange!.end)}',
                      ),
                    ),
                    if (_filterRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearDateRange,
                      ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _pickDateRange,
                    ),
                  ],
                ),
              ),

              // Sort dropdown
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButton<_SortOrder>(
                  value: _sortOrder,
                  isExpanded: true,
                  onChanged:
                      (v) => setState(() {
                        if (v != null) _sortOrder = v;
                      }),
                  items: [
                    DropdownMenuItem(
                      value: _SortOrder.newestFirst,
                      child: Text(loc.translate('repairs_sort_newest')),
                    ),
                    DropdownMenuItem(
                      value: _SortOrder.oldestFirst,
                      child: Text(loc.translate('repairs_sort_oldest')),
                    ),
                  ],
                ),
              ),

              // Active‐only switch
              SwitchListTile(
                title: Text(
                  _showAll
                      ? loc.translate('repairs_filter_active_only')
                      : loc.translate('repairs_filter_show_all'),
                ),
                secondary: const Icon(Icons.filter_list),
                value: _showAll,
                onChanged: (v) => setState(() => _showAll = v),
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
                    labelText: loc.translate('repairs_search'),
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged:
                      (v) =>
                          setState(() => _searchTerm = v.trim().toLowerCase()),
                ),
              ),
            ],
          ),

          const Divider(height: 1),

          // ─── results list ────────────────────────
          Expanded(
            child: FutureBuilder<List<RepairResponse>>(
              future: _repairs,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('❌ ${snap.error}'));
                }

                // 1) filter by status
                var list =
                    _showAll
                        ? snap.data!
                        : snap.data!
                            .where((r) => r.status == 'CREATED')
                            .toList();

                // 2) date-range filter
                if (_filterRange != null) {
                  list =
                      list.where((r) {
                        final d = DateTime.parse(r.createdAt!);
                        return !d.isBefore(_filterRange!.start) &&
                            !d.isAfter(_filterRange!.end);
                      }).toList();
                }

                // 3) search filter
                if (_searchTerm.isNotEmpty) {
                  list =
                      list.where((r) {
                        final term = _searchTerm;
                        return r.customerName.toLowerCase().contains(term) ||
                            r.surfboardName!.toLowerCase().contains(term) ||
                            r.issue.toLowerCase().contains(term);
                      }).toList();
                }

                // 4) sort
                list.sort((a, b) {
                  final da = DateTime.parse(a.createdAt!);
                  final db = DateTime.parse(b.createdAt!);
                  return _sortOrder == _SortOrder.newestFirst
                      ? db.compareTo(da)
                      : da.compareTo(db);
                });

                if (list.isEmpty) {
                  return Center(
                    child: Text(loc.translate('repairs_no_repairs_found')),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final r = list[i];
                    final statusEnum = repairStatusFromString(r.status);
                    final statusText = statusEnum.localized(loc);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // header row: index & name
                            Row(
                              children: [
                                CircleAvatar(child: Text('${i + 1}')),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${r.customerName} — ${r.surfboardName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // issue & status
                            Text(
                              '${loc.translate('repairs_issue')}: ${r.issue}',
                            ),
                            Text(
                              '${loc.translate('repairs_status_label')}: $statusText',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${loc.translate('repairs_created_at')}: '
                              '${dateFormat.format(DateTime.parse(r.createdAt!))}',
                            ),
                            const SizedBox(height: 12),
                            // action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children:
                                  statusEnum == RepairStatus.created
                                      ? [
                                        ElevatedButton(
                                          onPressed:
                                              () => _markAsRepaired(r.repairId),
                                          child: Text(
                                            loc.translate(
                                              'repairs_mark_as_repaired',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed:
                                              () => _cancelRepair(r.repairId),
                                          child: Text(
                                            loc.translate('repairs_cancel'),
                                          ),
                                        ),
                                      ]
                                      : [Text(statusText)],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
