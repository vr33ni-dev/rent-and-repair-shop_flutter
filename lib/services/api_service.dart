import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
