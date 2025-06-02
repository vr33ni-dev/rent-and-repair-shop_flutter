// lib/screens/overdue_returns_card.dart
import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/services/api_service.dart';
import 'package:rent_and_repair_shop_flutter/models/rental_response.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';

class OverdueReturnsCard extends StatefulWidget {
  const OverdueReturnsCard({super.key});

  @override
  State<OverdueReturnsCard> createState() => _OverdueReturnsCardState();
}

class _OverdueReturnsCardState extends State<OverdueReturnsCard> {
  late Future<List<RentalResponse>> _overdueFuture;

  @override
  void initState() {
    super.initState();
    // only fetching data here, no localization calls
    _overdueFuture = ApiService().fetchRentals();
  }

  String _daysOverdueLabel(BuildContext context, int days) {
    final loc = AppLocalizations.of(context);
    final key = days == 1 ? 'overdue_suffix_one' : 'overdue_suffix_other';
    return loc.translate(key).replaceAll('{days}', days.toString());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FutureBuilder<List<RentalResponse>>(
      future: _overdueFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('❌ ${snap.error}'));
        }

        // filter out only rentals that are still “created” but past endDate
        final now = DateTime.now();
        final overdue =
            snap.data!
                .where((r) {
                  if (r.status.toString().toLowerCase() != 'created') {
                    return false;
                  }
                  final end = DateTime.parse(r.returnedAt ?? '-');
                  return now.isAfter(end);
                })
                .map((r) {
                  final end = DateTime.parse(r.returnedAt ?? '-');
                  final days = now.difference(end).inDays;
                  return {
                    'label': '${r.surfboardName} – ${r.customerName}',
                    'days': days > 0 ? days : 0,
                  };
                })
                .toList();

        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // localized header
                Text(
                  loc.translate('overdue_returns'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (overdue.isEmpty) Text(loc.translate('overdue_none')),

                // render each overdue entry
                ...overdue.map((o) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(o['label'] as String)),
                        Text(
                          _daysOverdueLabel(context, o['days'] as int),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
