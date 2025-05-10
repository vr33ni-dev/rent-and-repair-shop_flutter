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

  @override
  void initState() {
    super.initState();
    _repairs = ApiService().fetchRepairs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Repairs')),
      body: FutureBuilder<List<RepairResponse>>(
        future: _repairs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No repairs found.'));
          }

          final repairs = snapshot.data!;
          return ListView.builder(
            itemCount: repairs.length,
            itemBuilder: (context, index) {
              final r = repairs[index];
              return ListTile(
                title: Text('${r.customerName} – ${r.surfboardName}'),
                subtitle: Text('Issue: ${r.issue} | Status: ${r.status}'),
                trailing: Text(r.createdAt.split('T').first),
              );
            },
          );
        },
      ),
    );
  }
}
