class RepairResponse {
  final String repairId;
  final String surfboardId;
  final String? customerId;
  final String? rentalId;
  final String surfboardName;
  final String customerName;
  final String issue;
  final String status;
  final String? createdAt;

  RepairResponse({
    required this.repairId,
    required this.surfboardId,
    required this.customerId,
    required this.rentalId,
    required this.surfboardName,
    required this.customerName,
    required this.issue,
    required this.status,
    required this.createdAt,
  });

  factory RepairResponse.fromJson(Map<String, dynamic> json) {
    return RepairResponse(
      repairId: json['repairId'],
      surfboardId: json['surfboardId'],
      customerId: json['customerId'],
      rentalId: json['rentalId'],
      surfboardName: json['surfboardName'],
      customerName: json['customerName'],
      issue: json['issue'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
