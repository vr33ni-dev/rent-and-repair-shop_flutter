import 'package:flutter/material.dart';
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
    final localizations = AppLocalizations.of(context);

    if (_formKey.currentState!.validate() && _selectedBoard != null) {
      final success = await ApiService().createRental(
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        surfboardId: _selectedBoard!.id,
        rentalFee: 0,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('rentals_rental_created'))),
        );

        // Clear the form state and controllers
        _formKey.currentState!.reset();
        _nameController.clear();
        _contactController.clear();

        // Reset the selected board and update state
        setState(() {
          _selectedBoard = null;
        });

        // Refresh rentals and available boards
        _fetchRentals();
        _fetchAvailableBoards();
      }
    }
  }

  Future<Map<String, dynamic>?> _showReturnDialog(BuildContext context) async {
    final damageDescriptionController = TextEditingController();
    final repairPriceController = TextEditingController();
    bool isDamaged = false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Return Board'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text('Is the board damaged?'),
                    value: isDamaged,
                    onChanged: (value) {
                      setState(() {
                        isDamaged = value ?? false;
                      });
                    },
                  ),
                  if (isDamaged) ...[
                    TextField(
                      controller: damageDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Damage Description',
                      ),
                    ),
                    TextField(
                      controller: repairPriceController,
                      decoration: InputDecoration(labelText: 'Repair Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'isDamaged': isDamaged,
                      'damageDescription':
                          isDamaged ? damageDescriptionController.text : null,
                      'repairPrice':
                          isDamaged
                              ? double.tryParse(repairPriceController.text)
                              : null,
                    });
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('rentals_create_new_rental'),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('rentals_customer_name'),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? localizations.translate('rentals_required')
                              : null,
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('rentals_contact_info'),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? localizations.translate('rentals_required')
                              : null,
                ),
                DropdownButtonFormField<Surfboard>(
                  decoration: InputDecoration(
                    labelText: localizations.translate('rentals_select_board'),
                  ),
                  items:
                      _availableBoards.map((board) {
                        return DropdownMenuItem(
                          value: board,
                          child: Text(board.name),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => _selectedBoard = val),
                  validator:
                      (val) =>
                          val == null
                              ? localizations.translate('rentals_select')
                              : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createRental,
                  child: Text(localizations.translate('rentals_create_rental')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          Text(
            localizations.translate('rentals_active_rentals'),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(
              _showHistory
                  ? localizations.translate('rentals_show_all_rentals')
                  : localizations.translate(
                    'rentals_show_rentals_active_rentals',
                  ),
            ),
            value: _showHistory,
            onChanged: (val) => setState(() => _showHistory = val),
            secondary: const Icon(Icons.filter_list),
          ),
          FutureBuilder<List<RentalResponse>>(
            future: _rentals,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('❌ ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    localizations.translate('rentals_no_rentals_found'),
                  ),
                );
              }

              final allRentals = snapshot.data!;
     

              final rentals =
                  _showHistory
                      ? allRentals
                      : allRentals
                          .where((r) => r.status == RentalStatus.created)
                          .toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  final r = rentals[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${r.rentalId}')),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.customerName} (ID: ${r.customerId})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${r.surfboardName} (ID: ${r.surfboardId})',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${localizations.translate('rentals_status')}: ${r.status}',
                        ),
                        Text(
                          '${localizations.translate('rentals_rented')}: ${r.rentedAt.split('T').first}',
                        ),
                        if (r.returnedAt != null)
                          Text(
                            '${localizations.translate('rentals_fee')}: \$${r.rentalFee?.toStringAsFixed(2)}',
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing:
                        r.status == RentalStatus.created
                            ? ElevatedButton(
                              child: const Text('Return'),
                              onPressed: () async {
                                final result = await _showReturnDialog(context);

                                if (result != null) {
                                  try {
                                    await ApiService().returnRental(
                                      r.rentalId,
                                      isDamaged: result['isDamaged'],
                                      damageDescription:
                                          result['damageDescription'],
                                      repairPrice: result['repairPrice'],
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Board returned successfully!',
                                        ),
                                      ),
                                    );

                                    setState(() {
                                      _rentals = ApiService().fetchRentals();
                                      _fetchAvailableBoards();
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
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
