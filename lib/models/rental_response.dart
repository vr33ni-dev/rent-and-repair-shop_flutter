import 'package:rent_and_repair_shop_flutter/enums/rental_status.dart';

class RentalResponse {
  final String rentalId;
  final String surfboardId;
  final String customerId;
  final double rentalFee;
  final String surfboardName;
  final String customerName;
  final String rentedAt;
  final String? returnedAt;
  final RentalStatus status;

  RentalResponse({
    required this.rentalId,
    required this.surfboardId,
    required this.customerId,
    required this.rentalFee,
    required this.surfboardName,
    required this.customerName,
    required this.rentedAt,
    this.returnedAt,
    required this.status,
  });

  factory RentalResponse.fromJson(Map<String, dynamic> json) {
    return RentalResponse(
      rentalId: json['rentalId'],
      surfboardId: json['surfboardId'],
      customerId: json['customerId'],
      rentalFee: (json['rentalFee'] as num).toDouble(),
      surfboardName: json['surfboardName'],
      customerName: json['customerName'],
      rentedAt: json['rentedAt'],
      returnedAt: json['returnedAt'],
      status: rentalStatusFromString(json['status']),
    );
  }
}
