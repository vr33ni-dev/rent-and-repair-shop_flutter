import 'package:flutter/material.dart';
import '../models/rental_response.dart';
import '../models/surfboard.dart';
import '../services/api_service.dart';

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});

  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  bool _showHistory = false; // ← new: whether to include returned rentals

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
    if (_formKey.currentState!.validate() && _selectedBoard != null) {
      final success = await ApiService().createRental(
        name: _nameController.text,
        contact: _contactController.text,
        surfboardId: _selectedBoard!.id,
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Rental created!')));
        _formKey.currentState!.reset();
        setState(() {
          _selectedBoard = null;
        });
        _fetchRentals();
        _fetchAvailableBoards();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📦 Create Rental', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Email or Phone',
                  ),
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<Surfboard>(
                  decoration: const InputDecoration(
                    labelText: 'Select Surfboard',
                  ),
                  items:
                      _availableBoards.map((board) {
                        return DropdownMenuItem(
                          value: board,
                          child: Text(board.name),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => _selectedBoard = val),
                  validator: (val) => val == null ? 'Choose one' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createRental,
                  child: const Text('Create Rental'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const Text('📋 Current Rentals', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          // Toggle switch
          SwitchListTile(
            title: Text(
              _showHistory
                  ? 'Showing all rentals'
                  : 'Showing only active rentals',
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
                return const Center(child: Text('No rentals found.'));
              }

              final allRentals = snapshot.data!;
              // ← NEW: apply the filter
              final rentals =
                  _showHistory
                      ? allRentals
                      : allRentals.where((r) => r.status == 'CREATED').toList();

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
                        Text('Status: ${r.status}'),
                        Text('Rented: ${r.rentedAt.split('T').first}'),
                        if (r.returnedAt != null)
                          Text('Returned: ${r.returnedAt!.split('T').first}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing:
                        r.status == 'CREATED'
                            ? ElevatedButton(
                              child: const Text('Return'),
                              onPressed: () async {
                                try {
                                  await ApiService().returnRental(r.rentalId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Board returned!'),
                                    ),
                                  );
                                  setState(() {
                                    _rentals = ApiService().fetchRentals();
                                    _fetchAvailableBoards();
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('❌ Error: $e')),
                                  );
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
