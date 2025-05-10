class RentalResponse {
  final int rentalId;
  final int surfboardId;
  final String surfboardName;
  final String customerName;
  final String status;
  final String rentedAt;

  RentalResponse({
    required this.rentalId,
    required this.surfboardId,
    required this.surfboardName,
    required this.customerName,
    required this.status,
    required this.rentedAt,
  });

  factory RentalResponse.fromJson(Map<String, dynamic> json) {
    return RentalResponse(
      rentalId: json['rentalId'],
      surfboardId: json['surfboardId'],
      surfboardName: json['surfboardName'],
      customerName: json['customerName'],
      status: json['status'],
      rentedAt: json['rentedAt'],
    );
  }
}
