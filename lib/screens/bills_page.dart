import 'package:flutter/material.dart';
import '../models/bill_response.dart';
import '../services/api_service.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late Future<List<BillResponse>> _bills;

  @override
  void initState() {
    super.initState();
    _bills = ApiService().fetchBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Bills')),
      body: FutureBuilder<List<BillResponse>>(
        future: _bills,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bills found.'));
          }

          final bills = snapshot.data!;
          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, i) {
              final b = bills[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${b.id}')),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${b.customerName} (ID: ${b.customerId})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (b.rentalId != null)
                      Text(
                        'Rental #${b.rentalId} • Repair #${b.repairId ?? "-"}',
                      ),
                  ],
                ),
                subtitle: Text(
                  'Fees: €${b.rentalFee.toStringAsFixed(2)} + '
                  '€${b.repairFee.toStringAsFixed(2)} = '
                  '€${b.totalAmount.toStringAsFixed(2)}\n'
                  'Status: ${b.status}',
                ),
                isThreeLine: true,
                trailing:
                    b.status != 'PAID'
                        ? ElevatedButton(
                          child: const Text('Mark Paid'),
                          onPressed: () async {
                            final success = await ApiService().payBill(b.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Bill marked as PAID'),
                                ),
                              );
                              // refresh the list
                              setState(() {
                                _bills = ApiService().fetchBills();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Failed to mark paid'),
                                ),
                              );
                            }
                          },
                        )
                        : const Text('✅ PAID'),
              );
            },
          );
        },
      ),
    );
  }
}
