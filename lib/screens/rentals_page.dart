import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_and_repair_shop_flutter/enums/rental_status.dart';
import '../models/rental_response.dart';
import '../models/surfboard.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});

  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  bool _showHistory = false;
  DateTimeRange? _filterRange;

  Surfboard? _selectedBoard;
  List<Surfboard> _availableBoards = [];
  late Future<List<RentalResponse>> _rentals;

  @override
  void initState() {
    super.initState();
    _fetchRentals();
    _fetchAvailableBoards();
  }

  void _fetchRentals() {
    setState(() {
      _rentals = ApiService().fetchRentals();
    });
  }

  Future<void> _fetchAvailableBoards() async {
    final boards = await ApiService().fetchAvailableSurfboards();
    setState(() => _availableBoards = boards);
  }

  Future<void> _createRental() async {
    final loc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate() && _selectedBoard != null) {
      final success = await ApiService().createRental(
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        surfboardId: _selectedBoard!.id,
        rentalFee: 15.0, // or whatever your default is
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('rentals_rental_created'))),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _contactController.clear();
        setState(() => _selectedBoard = null);
        _fetchRentals();
        _fetchAvailableBoards();
      }
    }
  }

  /// Shows the “Return Board” dialog, computes days×rate, lets user override.
  Future<Map<String, dynamic>?> _showReturnDialog({
    required BuildContext context,
    required DateTime rentedAt,
    required double dailyRate,
  }) {
    final loc = AppLocalizations.of(context);
    final damageDescCtrl = TextEditingController();
    final repairPriceCtrl = TextEditingController();
    final feeCtrl = TextEditingController();

    // compute inclusive days
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
                (ctx, setState) => AlertDialog(
                  title: Text(loc.translate('rentals_return')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        title: Text(loc.translate('rentals_damaged')),
                        value: isDamaged,
                        onChanged:
                            (v) => setState(() => isDamaged = v ?? false),
                      ),
                      if (isDamaged) ...[
                        TextField(
                          controller: damageDescCtrl,
                          decoration: InputDecoration(
                            labelText: loc.translate(
                              'rentals_damage_description',
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: repairPriceCtrl,
                          decoration: InputDecoration(
                            labelText: loc.translate('rentals_repair_price'),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      TextField(
                        controller: feeCtrl,
                        decoration: InputDecoration(
                          labelText:
                              '${loc.translate('rentals_total_fee')} (×$days days)',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
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
                          'damageDescription':
                              isDamaged ? damageDescCtrl.text : null,
                          'repairPrice':
                              isDamaged
                                  ? double.tryParse(repairPriceCtrl.text)
                                  : null,
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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final df = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Create New Rental ───────────────────
          Text(
            loc.translate('rentals_create_new_rental'),
            style: const TextStyle(fontSize: 20),
          ),
          SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate('rentals_customer_name'),
                  ),
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? loc.translate('rentals_required')
                              : null,
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: loc.translate('rentals_contact_info'),
                  ),
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? loc.translate('rentals_required')
                              : null,
                ),
                DropdownButtonFormField<Surfboard>(
                  decoration: InputDecoration(
                    labelText: loc.translate('rentals_select_board'),
                  ),
                  items:
                      _availableBoards
                          .map(
                            (b) =>
                                DropdownMenuItem(value: b, child: Text(b.name)),
                          )
                          .toList(),
                  onChanged: (b) => setState(() => _selectedBoard = b),
                  validator:
                      (v) => v == null ? loc.translate('rentals_select') : null,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createRental,
                  child: Text(loc.translate('rentals_create_rental')),
                ),
              ],
            ),
          ),

          SizedBox(height: 32),
          Divider(),

          // ─── Date-Range & Clear ─────────────────
          Row(
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
                  icon: Icon(Icons.clear),
                  tooltip: loc.translate('rentals_clear_filter'),
                  onPressed: () => setState(() => _filterRange = null),
                ),
              TextButton.icon(
                icon: Icon(Icons.date_range),
                label: Text(loc.translate('rentals_pick_range')),
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

          SizedBox(height: 16),
          // ─── Active / All Toggle ───────────────
          SwitchListTile(
            title: Text(
              _showHistory
                  ? loc.translate('rentals_show_all_rentals')
                  : loc.translate('rentals_show_rentals_active_rentals'),
            ),
            value: _showHistory,
            onChanged: (v) => setState(() => _showHistory = v),
            secondary: Icon(Icons.filter_list),
          ),

          // ─── Rentals List ───────────────────────
          FutureBuilder<List<RentalResponse>>(
            future: _rentals,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) return Center(child: Text('❌ ${snap.error}'));
              final all = snap.data ?? [];

              // 1) active vs history
              var filtered =
                  _showHistory
                      ? all
                      : all
                          .where((r) => r.status == RentalStatus.created)
                          .toList();

              // 2) date-range
              if (_filterRange != null) {
                filtered =
                    filtered.where((r) {
                      final d = DateTime.parse(r.rentedAt);
                      return !d.isBefore(_filterRange!.start) &&
                          !d.isAfter(_filterRange!.end);
                    }).toList();
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Text(loc.translate('rentals_no_rentals_found')),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final r = filtered[i];
                  final rentDate = DateTime.parse(r.rentedAt);
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(r.rentalId.substring(0, 4)),
                    ),
                    title: Text('${r.customerName} — ${r.surfboardName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${loc.translate('rentals_status')}: ${r.status}'),
                        Text(
                          '${loc.translate('rentals_rented')}: ${df.format(rentDate)}',
                        ),
                        if (r.returnedAt != null)
                          Text(
                            '${loc.translate('rentals_fee')}: \$${r.rentalFee.toStringAsFixed(2)}',
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing:
                        r.status == RentalStatus.created
                            ? ElevatedButton(
                              child: Text(loc.translate('rentals_return')),
                              onPressed: () async {
                                final result = await _showReturnDialog(
                                  context: context,
                                  rentedAt: rentDate,
                                  dailyRate: r.rentalFee ?? 15.0,
                                );
                                if (result == null) return;

                                await ApiService().returnRental(
                                  r.rentalId,
                                  isDamaged: result['isDamaged'],
                                  damageDescription:
                                      result['damageDescription'],
                                  repairPrice: result['repairPrice'],
                                  finalFee: result['finalFee'],
                                );
                                // refresh
                                _fetchRentals();
                                _fetchAvailableBoards();
                              },
                            )
                            : null,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
