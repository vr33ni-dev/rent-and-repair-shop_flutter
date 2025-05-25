class BillResponse {
  final String id;
  final String customerId;
  final String customerName;
  final String customerContact;
  final String customerContactType;
  final String description;
  final String? rentalId;
  final String? repairId;
  final double rentalFee;
  final double repairFee;
  final double totalAmount;
  final String status;
  final DateTime billCreatedAt;
  final DateTime? billPaidAt;
  final DateTime? rentalDate;
  final DateTime? rentalReturnDate;
  final DateTime? repairDate;

  BillResponse({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerContact,
    required this.customerContactType,
    this.description = '',
    this.rentalId,
    this.repairId,
    required this.rentalFee,
    required this.repairFee,
    required this.totalAmount,
    required this.status,
    required this.billCreatedAt,
    this.billPaidAt,
    this.rentalDate,
    this.rentalReturnDate,
    this.repairDate,
  });

  factory BillResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? s) =>
        s == null || s.isEmpty ? null : DateTime.tryParse(s);

    return BillResponse(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerContact: json['customerContact'] as String? ?? '—',
      customerContactType: json['customerContactType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rentalDate: parseDate(json['rentalDate'] as String?),
      rentalReturnDate: parseDate(json['rentalReturnDate'] as String?),
      repairDate: parseDate(json['repairDate'] as String?),
      billCreatedAt: DateTime.parse(json['billCreatedAt'] as String),
      billPaidAt: parseDate(json['billPaidAt'] as String?),
      rentalFee: (json['rentalFee'] as num?)?.toDouble() ?? 0.0,
      repairFee: (json['repairFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
    );
  }
}
