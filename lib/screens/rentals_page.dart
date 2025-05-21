import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_and_repair_shop_flutter/enums/rental_status.dart';
import '../models/rental_response.dart';
import '../models/surfboard.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

enum _SortOrder { newestFirst, oldestFirst }

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});
  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  late Future<List<RentalResponse>> _rentals;
  List<Surfboard> _availableBoards = [];

  // ── filter / sort state ──────────────────────────────────────
  bool _showHistory = false;
  DateTimeRange? _filterRange;
  _SortOrder _sortOrder = _SortOrder.newestFirst;
  String _searchTerm = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // default to the last 30 days:
    final now = DateTime.now();
    _filterRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    _loadData();
  }

  void _loadData() {
    setState(() {
      _rentals = ApiService().fetchRentals();
    });
    ApiService().fetchAvailableSurfboards().then((boards) {
      setState(() => _availableBoards = boards);
    });
  }

  // ── date‐range picker helpers ─────────────────────────────────
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

  void _clearDateRange() => setState(() => _filterRange = null);

  // ── “New Rental” dialog (unchanged) ─────────────────────────
  Future<void> _showCreateRentalDialog() async {
    final formKey = GlobalKey<FormState>();
    String? name, contact;
    Surfboard? chosenBoard;
    final loc = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setSt) => AlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('rentals_create_new_rental')),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.translate('rentals_boards_available')}: ${_availableBoards.length}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: loc.translate('rentals_customer_name'),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? loc.translate('rentals_required')
                                      : null,
                          onSaved: (v) => name = v?.trim(),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: loc.translate('rentals_contact_info'),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? loc.translate('rentals_required')
                                      : null,
                          onSaved: (v) => contact = v?.trim(),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Surfboard>(
                          isExpanded: true,
                          hint: Text(loc.translate('rentals_select_board')),
                          items:
                              _availableBoards.map((b) {
                                return DropdownMenuItem(
                                  value: b,
                                  child: Text(b.name),
                                );
                              }).toList(),
                          onChanged: (b) => setSt(() => chosenBoard = b),
                          validator:
                              (v) =>
                                  v == null
                                      ? loc.translate(
                                        'rentals_select_board_required',
                                      )
                                      : null,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(loc.translate('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          final ok = await ApiService().createRental(
                            name: name!,
                            contact: contact!,
                            surfboardId: chosenBoard!.id,
                            rentalFee: 15.0,
                          );
                          Navigator.of(ctx).pop();
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.translate('rentals_rental_created'),
                                ),
                              ),
                            );
                            _loadData();
                          }
                        }
                      },
                      child: Text(loc.translate('rentals_create_rental')),
                    ),
                  ],
                ),
          ),
    );
  }

  // ── “Return Board” dialog (unchanged) ────────────────────────
  Future<Map<String, dynamic>?> _showReturnDialog({
    required BuildContext context,
    required DateTime rentedAt,
    required double dailyRate,
  }) {
    final loc = AppLocalizations.of(context)!;
    final dmgCtrl = TextEditingController();
    final repCtrl = TextEditingController();
    final feeCtrl = TextEditingController();

    final now = DateTime.now();
    final days = now.difference(rentedAt).inDays + 1;
    final defaultFee = days * dailyRate;
    feeCtrl.text = defaultFee.toStringAsFixed(2);

    bool isDamaged = false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setSt) => AlertDialog(
                  title: Text(loc.translate('rentals_return')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        title: Text(loc.translate('rentals_damaged')),
                        value: isDamaged,
                        onChanged: (v) => setSt(() => isDamaged = v!),
                      ),
                      if (isDamaged) ...[
                        TextField(
                          controller: dmgCtrl,
                          decoration: InputDecoration(
                            labelText: loc.translate(
                              'rentals_damage_description',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: repCtrl,
                          decoration: InputDecoration(
                            labelText: loc.translate('rentals_repair_price'),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: feeCtrl,
                        decoration: InputDecoration(
                          labelText:
                              '${loc.translate('rentals_total_fee')} (×$days)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, null),
                      child: Text(loc.translate('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final finalFee =
                            double.tryParse(feeCtrl.text) ?? defaultFee;
                        Navigator.pop(ctx, {
                          'isDamaged': isDamaged,
                          'damageDescription': isDamaged ? dmgCtrl.text : null,
                          'repairPrice':
                              isDamaged ? double.tryParse(repCtrl.text) : null,
                          'finalFee': finalFee,
                        });
                      },
                      child: Text(loc.translate('confirm')),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      // appBar: AppBar(title: Text(loc.translate('rentals_title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRentalDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ─── Collapsible Filter Panel ─────────────────────────
          ExpansionTile(
            title: Text(loc.translate('rentals_filters_title')),
            childrenPadding: const EdgeInsets.symmetric(vertical: 4),
            children: [
              // Date‐Range Row
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
                            ? loc.translate('rentals_filter_by_date')
                            : '${df.format(_filterRange!.start)} → ${df.format(_filterRange!.end)}',
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

              // Sort Dropdown
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
                      child: Text(loc.translate('rentals_sort_newest')),
                    ),
                    DropdownMenuItem(
                      value: _SortOrder.oldestFirst,
                      child: Text(loc.translate('rentals_sort_oldest')),
                    ),
                  ],
                ),
              ),

              // Active‐only Switch
              SwitchListTile(
                title: Text(
                  _showHistory
                      ? loc.translate('rentals_filter_show_all')
                      : loc.translate('rentals_filter_active_only'),
                ),
                secondary: const Icon(Icons.filter_list),
                value: _showHistory,
                onChanged: (v) => setState(() => _showHistory = v),
              ),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    labelText: loc.translate('rentals_search'),
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

          // ─── Results List ──────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<RentalResponse>>(
              future: _rentals,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (snap.hasError)
                  return Center(child: Text('❌ ${snap.error}'));

                var list = snap.data ?? [];

                // 1) Active vs history
                if (!_showHistory) {
                  list =
                      list
                          .where((r) => r.status == RentalStatus.created)
                          .toList();
                }
                // 2) Date‐range filter
                if (_filterRange != null) {
                  list =
                      list.where((r) {
                        final d = DateTime.parse(r.rentedAt);
                        return !d.isBefore(_filterRange!.start) &&
                            !d.isAfter(_filterRange!.end);
                      }).toList();
                }
                // 3) Search filter
                if (_searchTerm.isNotEmpty) {
                  list =
                      list.where((r) {
                        return r.customerName.toLowerCase().contains(
                              _searchTerm,
                            ) ||
                            r.surfboardName.toLowerCase().contains(_searchTerm);
                      }).toList();
                }
                // 4) Sort
                list.sort((a, b) {
                  final da = DateTime.parse(a.rentedAt);
                  final db = DateTime.parse(b.rentedAt);
                  return _sortOrder == _SortOrder.newestFirst
                      ? db.compareTo(da)
                      : da.compareTo(db);
                });

                if (list.isEmpty) {
                  return Center(
                    child: Text(loc.translate('rentals_no_rentals_found')),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final r = list[i];
                    final rentedOn = DateTime.parse(r.rentedAt);
                    final statusText = r.status.localized(loc);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: index + name
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
                            Text(
                              '${loc.translate('rentals_status_label')}: $statusText',
                            ),
                            Text(
                              '${loc.translate('rentals_status_created')}: ${df.format(rentedOn)}',
                            ),
                            if (r.returnedAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${loc.translate('rentals_fee')}: '
                                '\$${r.rentalFee!.toStringAsFixed(2)}',
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children:
                                  r.status == RentalStatus.created
                                      ? [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final result =
                                                await _showReturnDialog(
                                                  context: context,
                                                  rentedAt: rentedOn,
                                                  dailyRate:
                                                      r.rentalFee ?? 15.0,
                                                );
                                            if (result != null) {
                                              await ApiService().returnRental(
                                                r.rentalId,
                                                isDamaged: result['isDamaged'],
                                                damageDescription:
                                                    result['damageDescription'],
                                                repairPrice:
                                                    result['repairPrice'],
                                                finalFee: result['finalFee'],
                                              );
                                              _loadData();
                                            }
                                          },
                                          child: Text(
                                            loc.translate('rentals_return'),
                                          ),
                                        ),
                                      ]
                                      : [],
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
