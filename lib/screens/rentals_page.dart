import 'package:flutter/material.dart';
import '../models/rental_response.dart';
import '../services/api_service.dart';

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});

  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  late Future<List<RentalResponse>> _rentals;

  @override
  void initState() {
    super.initState();
    _rentals = ApiService().fetchRentals();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RentalResponse>>(
      future: _rentals,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No rentals found.'));
        }

        final rentals = snapshot.data!;
        return ListView.builder(
          itemCount: rentals.length,
          itemBuilder: (context, index) {
            final r = rentals[index];
            return ListTile(
              title: Text('${r.customerName} – ${r.surfboardName}'),
              subtitle: Text('Status: ${r.status}'),
              trailing: Text(r.rentedAt.split('T').first),
            );
          },
        );
      },
    );
  }
}
