// lib/screens/bills_page.dart

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';
import '../models/bill_response.dart';
import '../services/api_service.dart';

enum _SortOrder { newestFirst, oldestFirst }

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});
  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<BillResponse>> _bills;

  // ─── filter & sort state ─────────────────────────
  bool _showOnlyUnpaid = true;
  _SortOrder _sortOrder = _SortOrder.newestFirst;
  DateTimeRange? _filterRange;
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // default to the last 30 days:
    final now = DateTime.now();
    _filterRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _bills = ApiService().fetchBills();
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

  /// re‐apply your filters & sorting to the raw list
  List<BillResponse> _applyFiltersAndSort(List<BillResponse> all) {
    var list = all;

    if (_showOnlyUnpaid) {
      list = list.where((b) => b.status != 'PAID').toList();
    }
    if (_filterRange != null) {
      list =
          list.where((b) {
            final d = b.billCreatedAt;
            return !d.isBefore(_filterRange!.start) &&
                !d.isAfter(_filterRange!.end);
          }).toList();
    }
    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      list =
          list
              .where((b) => b.customerName.toLowerCase().contains(term))
              .toList();
    }

    list.sort((a, b) {
      return _sortOrder == _SortOrder.newestFirst
          ? b.billCreatedAt.compareTo(a.billCreatedAt)
          : a.billCreatedAt.compareTo(b.billCreatedAt);
    });

    return list;
  }

  /// builds & shares a CSV of the currently filtered+sorted bills
  Future<void> _exportCsv() async {
    final loc = AppLocalizations.of(context)!;
    final all = await _bills;
    final filtered = _applyFiltersAndSort(all);

    // build CSV
    final rows = <List<dynamic>>[];

    // header
    rows.add([
      loc.translate('bills_csv_idx'),
      loc.translate('bills_csv_customer'),
      loc.translate('bills_csv_contact'),
      loc.translate('bills_csv_created'),
      loc.translate('bills_csv_paid_at'),
      loc.translate('bills_csv_total'),
      loc.translate('bills_csv_status'),
    ]);

    // data rows
    for (var i = 0; i < filtered.length; i++) {
      final b = filtered[i];
      rows.add([
        i + 1,
        b.customerName,
        '${b.customerContact} (${b.customerContactType})',
        DateFormat('yyyy-MM-dd').format(b.billCreatedAt),
        b.billPaidAt != null
            ? DateFormat('yyyy-MM-dd').format(b.billPaidAt!)
            : '',
        b.totalAmount.toStringAsFixed(2),
        b.status,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    // write to temp file
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/bills_export.csv';
    final file = File(path);
    await file.writeAsString(csvString);

    // share
    await Share.shareXFiles([
      XFile(path),
    ], text: loc.translate('bills_export_share_message'));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context)!;
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      // appBar: AppBar(title: Text(loc.translate('bills_title'))),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.download),
        label: Text(loc.translate('bills_export_csv')),
        onPressed: _exportCsv,
      ),
      body: FutureBuilder<List<BillResponse>>(
        future: _bills,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('❌ ${snap.error}'));
          }

          final list = _applyFiltersAndSort(snap.data!);

          return Column(
            children: [
              // ─── collapsible filter panel ─────────────────
              _buildFilterPanel(loc, df),

              // ─── bills list (or “no bills”) ───────────────
              if (list.isEmpty)
                Expanded(
                  child: Center(child: Text(loc.translate('bills_no_bills'))),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final b = list[i];
                      final paidAt =
                          b.billPaidAt != null ? df.format(b.billPaidAt!) : '–';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // index + customer name
                              Row(
                                children: [
                                  CircleAvatar(child: Text('${i + 1}')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      b.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // contact
                              Text(
                                '${b.customerContact} (${b.customerContactType})',
                              ),
                              const SizedBox(height: 8),
                              // dates
                              if (b.rentalDate != null)
                                Text(
                                  '${loc.translate('bills_rental_creation_date')}: '
                                  '${df.format(b.rentalDate!)}',
                                ),
                              if (b.repairDate != null)
                                Text(
                                  '${loc.translate('bills_repair_creation_date')}: '
                                  '${df.format(b.repairDate!)}',
                                ),
                              Text(
                                '${loc.translate('bills_bill_created')}: '
                                '${df.format(b.billCreatedAt)}',
                              ),
                              Text(
                                '${loc.translate('bills_bill_paid')}: $paidAt',
                              ),
                              const SizedBox(height: 8),
                              // amount & status
                              Text(
                                '${loc.translate('bills_price')}: '
                                '\$${b.rentalFee.toStringAsFixed(2)} + '
                                '\$${b.repairFee.toStringAsFixed(2)} = '
                                '\$${b.totalAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                '${loc.translate('bills_status')}: ${b.status}',
                              ),
                              const SizedBox(height: 12),
                              // action button or “Paid” label
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children:
                                    b.status != 'PAID'
                                        ? [
                                          ElevatedButton(
                                            onPressed: () async {
                                              final ok = await ApiService()
                                                  .payBill(b.id);
                                              if (ok) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      loc.translate(
                                                        'bills_marked_as_paid',
                                                      ),
                                                    ),
                                                  ),
                                                );
                                                _reload();
                                              }
                                            },
                                            child: Text(
                                              loc.translate(
                                                'bills_mark_as_paid',
                                              ),
                                            ),
                                          ),
                                        ]
                                        : [Text(loc.translate('bills_paid'))],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // // ─── export CSV button ────────────────────────
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16,
              //     vertical: 4,
              //   ),
              //   child: ElevatedButton.icon(
              //     icon: const Icon(Icons.download),
              //     label: Text(loc.translate('bills_export_csv')),
              //     onPressed: _exportCsv,
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  /// the ExpansionTile at the top
  Widget _buildFilterPanel(AppLocalizations loc, DateFormat df) {
    // ─── Collapsible Filter Panel ───────────────────

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
        child: ExpansionTile(
          title: Text(
            loc.translate('bills_filters_title'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(vertical: 4),
          children: [
            // your filter widgets (date range, dropdown, switch, search)
            // date range row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _filterRange == null
                          ? loc.translate('bills_filter_by_date')
                          : '${df.format(_filterRange!.start)} → '
                              '${df.format(_filterRange!.end)}',
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

            // sort dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    child: Text(loc.translate('bills_sort_newest')),
                  ),
                  DropdownMenuItem(
                    value: _SortOrder.oldestFirst,
                    child: Text(loc.translate('bills_sort_oldest')),
                  ),
                ],
              ),
            ),

            // unpaid‐only switch
            SwitchListTile(
              title: Text(
                _showOnlyUnpaid
                    ? loc.translate('bills_filter_unpaid_only')
                    : loc.translate('bills_filter_include_paid'),
              ),
              secondary: const Icon(Icons.money_off),
              value: _showOnlyUnpaid,
              onChanged: (v) => setState(() => _showOnlyUnpaid = v),
            ),

            // search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: loc.translate('bills_search'),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged:
                    (v) => setState(() => _searchTerm = v.trim().toLowerCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
