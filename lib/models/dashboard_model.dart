class DashboardOverviewModel {
  final int totalRecordsImported;
  final int totalCollectedRecords;
  final double totalExpectedAmount;
  final double totalCollectedAmount;
  final double progressPercentage;

  DashboardOverviewModel({
    required this.totalRecordsImported,
    required this.totalCollectedRecords,
    required this.totalExpectedAmount,
    required this.totalCollectedAmount,
    required this.progressPercentage,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalRecordsImported: json['totalRecordsImported'] ?? 0,
      totalCollectedRecords: json['totalCollectedRecords'] ?? 0,
      totalExpectedAmount: (json['totalExpectedAmount'] ?? 0).toDouble(),
      totalCollectedAmount: (json['totalCollectedAmount'] ?? 0).toDouble(),
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
    );
  }
}

class ConsultantPerformanceModel {
  final int consultantId;
  final String consultantName;
  final int targetRecords;
  final double targetAmount;
  final int collectedRecords;
  final double collectedAmount;

  ConsultantPerformanceModel({
    required this.consultantId,
    required this.consultantName,
    required this.targetRecords,
    required this.targetAmount,
    required this.collectedRecords,
    required this.collectedAmount,
  });

  factory ConsultantPerformanceModel.fromJson(Map<String, dynamic> json) {
    return ConsultantPerformanceModel(
      consultantId: json['consultantId'] ?? 0,
      consultantName: json['consultantName'] ?? '',
      targetRecords: json['targetRecords'] ?? 0,
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      collectedRecords: json['collectedRecords'] ?? 0,
      collectedAmount: (json['collectedAmount'] ?? 0).toDouble(),
    );
  }

  double get progress {
    if (targetRecords == 0) return 0;
    return collectedRecords / targetRecords;
  }
}

class ConsultantDailyStatsModel {
  final int consultantId;
  final String consultantName;
  final DateTime? firstBillPrintedAt;
  final int collectedCount;

  ConsultantDailyStatsModel({
    required this.consultantId,
    required this.consultantName,
    required this.firstBillPrintedAt,
    required this.collectedCount,
  });

  factory ConsultantDailyStatsModel.fromJson(Map<String, dynamic> json) {
    return ConsultantDailyStatsModel(
      consultantId: json['consultantId'] ?? 0,
      consultantName: json['consultantName'] ?? '',
      firstBillPrintedAt: json['firstBillPrintedAt'] != null
          ? DateTime.tryParse(json['firstBillPrintedAt'])
          : null,
      collectedCount: json['collectedCount'] ?? 0,
    );
  }
}
