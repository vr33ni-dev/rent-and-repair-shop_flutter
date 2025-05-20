// lib/screens/bills_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void _reload() {
    setState(() {
      _bills = ApiService().fetchBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('bills_title'))),
      body: FutureBuilder<List<BillResponse>>(
        future: _bills,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('❌ ${snap.error}'));
          }

          final bills = snap.data!;
          if (bills.isEmpty) {
            return Center(child: Text(loc.translate('bills_no_bills')));
          }

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (ctx, i) {
              final b = bills[i];
              // show “Paid at” or “–” if null
              final paidAtText =
                  b.billPaidAt != null ? df.format(b.billPaidAt!) : '–';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(
                    b.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // contact + type
                      Text('${b.customerContact} (${b.customerContactType})'),
                      const SizedBox(height: 8),
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
                      Text('${loc.translate('bills_bill_paid')}: $paidAtText'),
                      const SizedBox(height: 8),
                      Text(
                        '${loc.translate('bills_price')}: '
                        '\$${b.rentalFee.toStringAsFixed(2)} + '
                        '\$${b.repairFee.toStringAsFixed(2)} = '
                        '\$${b.totalAmount.toStringAsFixed(2)}',
                      ),
                      Text('${loc.translate('bills_status')}: ${b.status}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing:
                      b.status != 'PAID'
                          ? ElevatedButton(
                            child: Text(loc.translate('bills_mark_as_paid')),
                            onPressed: () async {
                              final ok = await ApiService().payBill(b.id);
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loc.translate('bills_marked_as_paid'),
                                    ),
                                  ),
                                );
                                _reload();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loc.translate(
                                        'bills_could_not_mark_as_paid',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                          : Text(loc.translate('bills_paid')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
