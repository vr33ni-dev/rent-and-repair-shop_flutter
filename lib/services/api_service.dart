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
    required int surfboardId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerName': name,
        'customerContact': contact,
        'surfboardId': surfboardId,
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

  Future<void> returnRental(int rentalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals/$rentalId/return'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to return rental');
    }
  }

  Future<List<RepairResponse>> fetchRepairs() async {
    final response = await http.get(Uri.parse('$baseUrl/repairs/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => RepairResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load repairs');
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
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BillResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bills');
    }
  }

  /// Marks the given bill as paid.
  Future<bool> payBill(int id) async {
    final url = Uri.parse('$baseUrl/bills/$id/pay');
    final resp = await http.post(url);
    return resp.statusCode == 200;
  }
}
