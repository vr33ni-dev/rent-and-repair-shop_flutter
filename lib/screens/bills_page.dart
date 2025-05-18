import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('bills_title')),
      ),
      body: FutureBuilder<List<BillResponse>>(
        future: _bills,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(localizations.translate('bills_no_bills')),
            );
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
                        localizations.translate('bills_rental_and_repair')
                            .replaceAll('{{rentalId}}', '${b.rentalId}')
                            .replaceAll('{{repairId}}', '${b.repairId ?? "-"}'),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${localizations.translate('bills_price')}: \$${b.rentalFee.toStringAsFixed(2)} + '
                  '\$${b.repairFee.toStringAsFixed(2)} = '
                  '\$${b.totalAmount.toStringAsFixed(2)}\n'
                  '${localizations.translate('bills_status')}: ${b.status}',
                ),
                isThreeLine: true,
                trailing: b.status != 'PAID'
                    ? ElevatedButton(
                        child: Text(localizations.translate('bills_mark_as_paid')),
                        onPressed: () async {
                          final success = await ApiService().payBill(b.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.translate('bills_marked_as_paid')),
                              ),
                            );
                            // Refresh the list
                            setState(() {
                              _bills = ApiService().fetchBills();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.translate('bills_could_not_mark_as_paid')),
                              ),
                            );
                          }
                        },
                      )
                    : Text(localizations.translate('bills_paid')),
              );
            },
          );
        },
      ),
    );
  }
}