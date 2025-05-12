class RentalResponse {
  final int rentalId;
  final int surfboardId;
  final int customerId;
  final String surfboardName;
  final String customerName;
  final String status;
  final String rentedAt;
  final String? returnedAt;

  RentalResponse({
    required this.rentalId,
    required this.surfboardId,
    required this.customerId,
    required this.surfboardName,
    required this.customerName,
    required this.status,
    required this.rentedAt,
    required this.returnedAt,
  });

  factory RentalResponse.fromJson(Map<String, dynamic> json) {
    return RentalResponse(
      rentalId: json['rentalId'],
      surfboardId: json['surfboardId'],
      customerId: json['customerId'],
      surfboardName: json['surfboardName'],
      customerName: json['customerName'],
      status: json['status'],
      rentedAt: json['rentedAt'],
      returnedAt: json['returnedAt'],
    );
  }
}
