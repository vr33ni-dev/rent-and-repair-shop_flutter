import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rent_and_repair_shop_flutter/models/bill_response.dart';
import 'package:rent_and_repair_shop_flutter/models/surfboard.dart';
import '../models/rental_response.dart';
import '../models/repair_response.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<List<RentalResponse>> fetchRentals() async {
    final url = Uri.parse('$baseUrl/rentals/all');
    print('🔍 Fetching rentals from: $url');

    try {
      final response = await http.get(url);

      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => RentalResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rentals');
      }
    } catch (e) {
      print('❌ Error occurred: $e');
      rethrow;
    }
  }

  Future<bool> createRental({
    required String name,
    required String contact,
    required String surfboardId,
    required double rentalFee,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerName': name,
        'customerContact': contact,
        'surfboardId': surfboardId,
        'rentalFee': rentalFee,
      }),
    );
    return response.statusCode == 200;
  }

  Future<List<Surfboard>> fetchAvailableSurfboards() async {
    final response = await http.get(Uri.parse('$baseUrl/surfboards/available'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Surfboard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load boards');
    }
  }

  Future<void> returnRental(
    String rentalId, {
    required bool isDamaged,
    String? damageDescription,
    double? repairPrice,
    required double finalFee, // ← add this
  }) async {
    final url = Uri.parse('$baseUrl/rentals/$rentalId/return');
    final body = {
      'isDamaged': isDamaged,
      if (damageDescription != null) 'damageDescription': damageDescription,
      if (repairPrice != null) 'repairPrice': repairPrice,
      'finalFee': finalFee, // ← and send it
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to return rental: ${response.body}');
    }
  }

  /// Create a new repair for a customer-owned board
  Future<bool> createRepair({
    required String customerName,
    required String customerContact,
    required String surfboardName,
    required String issue,
    required double repairFee,
  }) async {
    final url = Uri.parse('$baseUrl/repairs');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerName': customerName,
        'customerContact': customerContact,
        'surfboardName': surfboardName,
        'issue': issue,
        'repairFee': repairFee,
      }),
    );
    return response.statusCode == 200;
  }

  /// Cancel an existing repair
  Future<bool> cancelRepair(String repairId) async {
    final url = Uri.parse('$baseUrl/repairs/$repairId/cancel');
    final resp = await http.post(url);
    return resp.statusCode == 200;
  }

  Future<List<RepairResponse>> fetchRepairs() async {
    final response = await http.get(Uri.parse('$baseUrl/repairs/all'));
    print('GET body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => RepairResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load repairs');
    }
  }

  Future<void> markRepairAsCompleted(String repairId) async {
    final url = Uri.parse('$baseUrl/repairs/$repairId/complete');
    final response = await http.post(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to mark repair as completed');
    }
  }

  Future<List<Surfboard>> fetchSurfboards() async {
    final response = await http.get(Uri.parse('$baseUrl/surfboards/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Surfboard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surfboards');
    }
  }

  Future<List<BillResponse>> fetchBills() async {
    final response = await http.get(Uri.parse('$baseUrl/bills/all'));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      print('💵 raw bills JSON: ${response.body}');
      return list
          .map((item) => BillResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load bills');
    }
  }

  /// Marks the given bill as paid.
  Future<bool> payBill(String id) async {
    final url = Uri.parse('$baseUrl/bills/$id/pay');
    final resp = await http.post(url);
    return resp.statusCode == 200;
  }

  /// Creates a new shop-owned surfboard.
  Future<bool> createSurfboard({
    required String name,
    String? description,
    String? sizeText,
    required bool damaged,
    String? issue,
  }) async {
    final url = Uri.parse('$baseUrl/surfboards');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        if (sizeText != null && sizeText.isNotEmpty) 'sizeText': sizeText,
        'damaged': damaged,
        'issue': issue,
      }),
    );
    return response.statusCode == 200;
  }
}
