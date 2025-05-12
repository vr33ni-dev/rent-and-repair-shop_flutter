class BillResponse {
  final int id;
  final int customerId;
  final String customerName;
  final int? rentalId;
  final int? repairId;
  final double rentalFee;
  final double repairFee;
  final double totalAmount;
  final String status;
  final DateTime billCreatedAt;
  final DateTime? rentalDate;
  final DateTime? repairDate;

  BillResponse({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.rentalId,
    this.repairId,
    required this.rentalFee,
    required this.repairFee,
    required this.totalAmount,
    required this.status,
    required this.billCreatedAt,
    this.rentalDate,
    this.repairDate,
  });

  factory BillResponse.fromJson(Map<String, dynamic> json) {
    return BillResponse(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      rentalId: json['rentalId'],
      repairId: json['repairId'],
      rentalFee: json['rentalFee'],
      repairFee: json['repairFee'],
      totalAmount: json['totalAmount'],
      status: json['status'],
      billCreatedAt: DateTime.parse(json['billCreatedAt']),
      rentalDate:
          json['rentalDate'] != null
              ? DateTime.parse(json['rentalDate'])
              : null,
      repairDate:
          json['repairDate'] != null
              ? DateTime.parse(json['repairDate'])
              : null,
    );
  }
}
