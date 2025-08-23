import 'package:flutter/material.dart';
import 'package:rent_and_repair_shop_flutter/services/api_service.dart';
import 'package:rent_and_repair_shop_flutter/models/rental_response.dart';
import 'package:rent_and_repair_shop_flutter/models/repair_response.dart';
import 'package:rent_and_repair_shop_flutter/l10n/app_localizations.dart';

/// Minimal event data: type + boardName + timestamp
class _Activity {
  final String type; // "new_rental" | "returned" | "new_repair"
  final String boardName;
  final DateTime timestamp;
  const _Activity({
    required this.type,
    required this.boardName,
    required this.timestamp,
  });
}

class RecentActivityCard extends StatefulWidget {
  const RecentActivityCard({super.key});
  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard> {
  late Future<List<_Activity>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    // fetch raw events (no translations here)
    _eventsFuture = _fetchActivities();
  }

  Future<List<_Activity>> _fetchActivities() async {
    final rentals = await ApiService().fetchRentals();
    final repairs = await ApiService().fetchRepairs();
    final events = <_Activity>[];

    for (var r in rentals) {
      final rentedAt = DateTime.parse(r.rentedAt);
      events.add(
        _Activity(
          type: 'new_rental',
          boardName: r.surfboardName,
          timestamp: rentedAt,
        ),
      );

      if (r.returnedAt != null) {
        final returnedAt = DateTime.parse(r.returnedAt!);
        events.add(
          _Activity(
            type: 'returned',
            boardName: r.surfboardName,
            timestamp: returnedAt,
          ),
        );
      }
    }

    for (var rp in repairs) {
      final createdAt = DateTime.parse(rp.createdAt!);
      events.add(
        _Activity(
          type: 'new_repair',
          boardName: rp.surfboardName ?? '-',
          timestamp: createdAt,
        ),
      );
    }

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(5).toList();
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FutureBuilder<List<_Activity>>(
      future: _eventsFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('❌ ${snap.error}'));
        }
        final events = snap.data!;

        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('recent_activity'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (events.isEmpty) Text(loc.translate('recent_activity_none')),
                for (var e in events)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // localize here based on e.type
                        Expanded(
                          child: Text(
                            (() {
                              switch (e.type) {
                                case 'new_rental':
                                  return loc
                                      .translate('recent_activity_new_rental')
                                      .replaceAll('{boardName}', e.boardName);
                                case 'returned':
                                  return loc
                                      .translate('recent_activity_returned')
                                      .replaceAll('{boardName}', e.boardName);
                                case 'new_repair':
                                  return loc
                                      .translate('recent_activity_new_repair')
                                      .replaceAll('{boardName}', e.boardName);
                                default:
                                  return e.boardName;
                              }
                            })(),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(e.timestamp),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
