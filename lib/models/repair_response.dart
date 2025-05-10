class RepairResponse {
  final int repairId;
  final int surfboardId;
  final String surfboardName;
  final String customerName;
  final String issue;
  final String status;
  final String createdAt;

  RepairResponse({
    required this.repairId,
    required this.surfboardId,
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
      surfboardName: json['surfboardName'],
      customerName: json['customerName'],
      issue: json['issue'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
