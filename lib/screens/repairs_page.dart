import 'package:flutter/material.dart';
import '../models/repair_response.dart';
import '../services/api_service.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  late Future<List<RepairResponse>> _repairs;
  bool _showHistory = false; // ← new: toggle to include completed/canceled

  @override
  void initState() {
    super.initState();
    _repairs = ApiService().fetchRepairs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repairs Dashboard')),
      body: FutureBuilder<List<RepairResponse>>(
        future: _repairs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('❌ ${snapshot.error?.toString() ?? "Unknown error"}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No repairs found.'));
          }

          final allRepairs = snapshot.data!;
          // filter for only open repairs when history is off
          final repairs =
              _showHistory
                  ? allRepairs
                  : allRepairs.where((r) => r.status == 'CREATED').toList();

          return Column(
            children: [
              // Toggle to show history or only active
              SwitchListTile(
                title: Text(
                  _showHistory
                      ? 'Showing all repairs'
                      : 'Showing only active repairs',
                ),
                secondary: const Icon(Icons.filter_list),
                value: _showHistory,
                onChanged: (val) => setState(() => _showHistory = val),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: repairs.length,
                  itemBuilder: (context, index) {
                    final r = repairs[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${r.repairId}')),
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
                          if (r.rentalId != null)
                            Text('Rental ID: ${r.rentalId}'),
                          Text('Issue: ${r.issue}'),
                          Text('Status: ${r.status}'),
                        ],
                      ),
                      trailing: Text(r.createdAt?.split('T').first ?? 'N/A'),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
