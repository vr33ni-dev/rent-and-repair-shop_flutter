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

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  void _loadRepairs() {
    _repairs = ApiService().fetchRepairs();
  }

  Future<void> _markAsRepaired(String repairId) async {
    final local = AppLocalizations.of(context)!;
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
    final local = AppLocalizations.of(context)!;
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
    final _formKey = GlobalKey<FormState>();
    String? customerName;
    String? customerContact;
    String? surfboardName;
    String? issue;
    String? feeText;

    final local = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(local.translate('repairs_new_repair')),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: local.translate('repairs_customer_name')),
                  onSaved: (v) => customerName = v,
                  validator: (v) => v == null || v.isEmpty ? local.translate('field_required') : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: local.translate('repairs_customer_contact')),
                  onSaved: (v) => customerContact = v,
                  validator: (v) => v == null || v.isEmpty ? local.translate('field_required') : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: local.translate('repairs_board')),
                  onSaved: (v) => surfboardName = v,
                  validator: (v) => v == null || v.isEmpty ? local.translate('field_required') : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: local.translate('repairs_issue')),
                  onSaved: (v) => issue = v,
                  validator: (v) => v == null || v.isEmpty ? local.translate('field_required') : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: local.translate('repairs_fee')),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => feeText = v,
                  validator: (v) => v == null || double.tryParse(v) == null ? local.translate('invalid_number') : null,
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
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
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
                    SnackBar(content: Text(local.translate('repairs_error_creating'))),
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
    final local = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(local.translate('repairs_title'))),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showCreateRepairDialog,
      ),
      body: FutureBuilder<List<RepairResponse>>(
        future: _repairs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          }

          final allRepairs = snapshot.data ?? [];
          final repairs = (_showAll ? allRepairs : allRepairs.where((r) => r.status == 'CREATED').toList())
            ..sort((a, b) {
              final da = DateTime.parse(a.createdAt!);
              final db = DateTime.parse(b.createdAt!);
              return _sortOrder == _SortOrder.newestFirst
                  ? db.compareTo(da)
                  : da.compareTo(db);
            });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<_SortOrder>(
                  value: _sortOrder,
                  isExpanded: true,
                  onChanged: (_SortOrder? v) {
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
              Expanded(
                child: ListView.builder(
                  itemCount: repairs.length,
                  itemBuilder: (context, index) {
                    final r = repairs[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(r.repairId.substring(0, 4))),
                      title: Text('${r.customerName} — ${r.surfboardName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (r.rentalId != null)
                            Text('${local.translate('repairs_rental_id')}: ${r.rentalId}'),
                          Text('${local.translate('repairs_issue')}: ${r.issue}'),
                          Text('${local.translate('repairs_status')}: ${r.status}'),
                          if (r.createdAt != null)
                            Text(
                              '${local.translate('repairs_created_at')}: '
                              '${dateFormat.format(DateTime.parse(r.createdAt!))}',
                            ),
                        ],
                      ),
                      trailing: r.status == 'CREATED'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _markAsRepaired(r.repairId),
                                  child: Text(local.translate('repairs_mark_as_repaired')),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => _cancelRepair(r.repairId),
                                  child: Text(local.translate('repairs_cancel')),
                                ),
                              ],
                            )
                          : Text(
                              r.status == 'COMPLETED'
                                  ? local.translate('repairs_completed')
                                  : local.translate('repairs_canceled'),
                            ),
                      isThreeLine: true,
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
