import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';
import '../models/repair_response.dart';
import '../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  void _loadRepairs() {
    _repairs = ApiService().fetchRepairs();
  }

  Future<void> _markAsRepaired(String repairId) async {
    final local = AppLocalizations.of(context);
    try {
      await ApiService().markRepairAsCompleted(repairId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.translate('repairs_marked_as_completed'))),
      );
      setState(_loadRepairs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${local.translate('repairs_error')}: $e')),
      );
    }
  }

  Future<void> _cancelRepair(String repairId) async {
    final local = AppLocalizations.of(context);
    try {
      final ok = await ApiService().cancelRepair(repairId);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(local.translate('repairs_canceled'))),
        );
        setState(_loadRepairs);
      } else {
        throw Exception('Cancel failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${local.translate('repairs_error')}: $e')),
      );
    }
  }

  void _showCreateRepairDialog() {
    final formKey = GlobalKey<FormState>();
    String? customerName, customerContact, surfboardName, issue, feeText;
    final local = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(local.translate('repairs_new_repair')),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: local.translate('repairs_customer_name'),
                      ),
                      onSaved: (v) => customerName = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? local.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: local.translate('repairs_customer_contact'),
                      ),
                      onSaved: (v) => customerContact = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? local.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: local.translate('repairs_board'),
                      ),
                      onSaved: (v) => surfboardName = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? local.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: local.translate('repairs_issue'),
                      ),
                      onSaved: (v) => issue = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? local.translate('field_required')
                                  : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: local.translate('repairs_fee'),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => feeText = v,
                      validator:
                          (v) =>
                              v == null || double.tryParse(v) == null
                                  ? local.translate('invalid_number')
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(local.translate('cancel')),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: Text(local.translate('repairs_create')),
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
                    if (ok) {
                      setState(_loadRepairs);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            local.translate('repairs_error_creating'),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(local.translate('repairs_title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRepairDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ─────────── Date‐Range Picker ───────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _filterRange == null
                        ? local.translate('repairs_filter_by_date')
                        : '${dateFormat.format(_filterRange!.start)} → ${dateFormat.format(_filterRange!.end)}',
                  ),
                ),
                if (_filterRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: local.translate('repairs_clear_filter'),
                    onPressed: () => setState(() => _filterRange = null),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(local.translate('repairs_pick_range')),
                  onPressed: () async {
                    final now = DateTime.now();
                    final lastYear = DateTime(now.year - 1, now.month, now.day);
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: lastYear,
                      lastDate: now,
                      initialDateRange: _filterRange,
                    );
                    if (picked != null) setState(() => _filterRange = picked);
                  },
                ),
              ],
            ),
          ),

          // ─────────── Sort & “Show All” Toggle ───────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<_SortOrder>(
              value: _sortOrder,
              isExpanded: true,
              onChanged: (v) {
                if (v != null) setState(() => _sortOrder = v);
              },
              items: [
                DropdownMenuItem(
                  value: _SortOrder.newestFirst,
                  child: Text(local.translate('repairs_sort_newest')),
                ),
                DropdownMenuItem(
                  value: _SortOrder.oldestFirst,
                  child: Text(local.translate('repairs_sort_oldest')),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(
              _showAll
                  ? local.translate('repairs_filter_active_only')
                  : local.translate('repairs_filter_show_all'),
            ),
            secondary: const Icon(Icons.filter_list),
            value: _showAll,
            onChanged: (v) => setState(() => _showAll = v),
          ),

          const Divider(),

          // ─────────── Repairs List ───────────
          Expanded(
            child: FutureBuilder<List<RepairResponse>>(
              future: _repairs,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('❌ ${snap.error}'));
                }
                var list =
                    _showAll
                        ? snap.data!
                        : snap.data!
                            .where((r) => r.status == 'CREATED')
                            .toList();

                // 1) date‐range filter
                if (_filterRange != null) {
                  list =
                      list.where((r) {
                        if (r.createdAt == null) return false;
                        final d = DateTime.parse(r.createdAt!);
                        return !d.isBefore(_filterRange!.start) &&
                            !d.isAfter(_filterRange!.end);
                      }).toList();
                }

                // 2) sort, defaulting null‐dates to epoch
                list.sort((a, b) {
                  final da =
                      a.createdAt != null
                          ? DateTime.parse(a.createdAt!)
                          : DateTime.fromMillisecondsSinceEpoch(0);
                  final db =
                      b.createdAt != null
                          ? DateTime.parse(b.createdAt!)
                          : DateTime.fromMillisecondsSinceEpoch(0);
                  return _sortOrder == _SortOrder.newestFirst
                      ? db.compareTo(da)
                      : da.compareTo(db);
                });

                if (list.isEmpty) {
                  return Center(
                    child: Text(local.translate('repairs_no_repairs_found')),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final r = list[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text('${r.customerName} — ${r.surfboardName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (r.rentalId != null)
                            Text(
                              '${local.translate('repairs_rental_id')}: ${r.rentalId}',
                            ),
                          Text(
                            '${local.translate('repairs_issue')}: ${r.issue}',
                          ),
                          Text(
                            '${local.translate('repairs_status')}: ${r.status}',
                          ),
                          if (r.createdAt != null)
                            Text(
                              '${local.translate('repairs_created_at')}: '
                              '${dateFormat.format(DateTime.parse(r.createdAt!))}',
                            ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing:
                          r.status == 'CREATED'
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        () => _markAsRepaired(r.repairId),
                                    child: Text(
                                      local.translate(
                                        'repairs_mark_as_repaired',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => _cancelRepair(r.repairId),
                                    child: Text(
                                      local.translate('repairs_cancel'),
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                r.status == 'COMPLETED'
                                    ? local.translate('repairs_completed')
                                    : local.translate('repairs_canceled'),
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
