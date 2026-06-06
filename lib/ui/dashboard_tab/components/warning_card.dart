import 'package:flutter/material.dart';

import '../../helpers/format_helper.dart';

class WarningCard extends StatelessWidget {
  final dynamic item;
  final bool compact;
  final VoidCallback? onTap;

  const WarningCard({
    super.key,
    required this.item,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warning = WarningViewModel.fromDynamic(item);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: warning.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: warning.color.withOpacity(0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: warning.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(warning.icon, color: warning.color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    warning.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: warning.color,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),

            const SizedBox(height: 14),

            if (warning.customerName.isNotEmpty)
              _InfoRow(
                icon: Icons.person_outline,
                label: "Khách hàng",
                value: warning.customerName,
              ),

            if (warning.customerCode.isNotEmpty)
              _InfoRow(
                icon: Icons.badge_outlined,
                label: "Mã KH",
                value: warning.customerCode,
              ),

            if (!compact && warning.phoneNumber.isNotEmpty)
              _InfoRow(
                icon: Icons.phone,
                label: "SĐT",
                value: warning.phoneNumber,
              ),

            if (!compact && warning.subscriberNumber.isNotEmpty)
              _InfoRow(
                icon: Icons.receipt_long,
                label: "Thuê bao",
                value: warning.subscriberNumber,
              ),

            if (warning.periodName.isNotEmpty)
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: "Kỳ cước",
                value: warning.periodName,
              ),

            if (warning.amountDue.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Số tiền",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      warning.amountDue,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.black45),
          const SizedBox(width: 8),
          SizedBox(
            width: 112,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class WarningViewModel {
  final String title;
  final String customerName;
  final String customerCode;
  final String phoneNumber;
  final String subscriberNumber;
  final String periodName;
  final String amountDue;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const WarningViewModel({
    required this.title,
    required this.customerName,
    required this.customerCode,
    required this.phoneNumber,
    required this.subscriberNumber,
    required this.periodName,
    required this.amountDue,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  factory WarningViewModel.fromDynamic(dynamic item) {
    if (item is Map<String, dynamic>) {
      final collectionStatus = item["collectionStatus"]?.toString() ?? "";
      final debtStatus = item["debtStatus"]?.toString() ?? "";
      final syncWarning = item["syncWarning"]?.toString() ?? "";
      final syncWarningNote = item["syncWarningNote"]?.toString().trim() ?? "";

      final customerName = item["customerName"]?.toString() ?? "";
      final customerCode = item["customerCode"]?.toString() ?? "";
      final phoneNumber = item["phoneNumber"]?.toString() ?? "";
      final subscriberNumber = item["subscriberNumber"]?.toString() ?? "";
      final periodName = item["billingPeriodName"]?.toString() ?? "";

      final rawAmountDue = item["amountDue"];
      final amountDue = rawAmountDue == null
          ? ""
          : FormatHelper.formatMoney(
              num.tryParse(rawAmountDue.toString()) ?? 0,
            );

      final title = _buildTitle(
        collectionStatus: collectionStatus,
        debtStatus: debtStatus,
        syncWarning: syncWarning,
        syncWarningNote: syncWarningNote,
      );

      final style = _buildStyle(
        collectionStatus: collectionStatus,
        debtStatus: debtStatus,
        syncWarning: syncWarning,
      );

      return WarningViewModel(
        title: title,
        customerName: customerName,
        customerCode: customerCode,
        phoneNumber: phoneNumber,
        subscriberNumber: subscriberNumber,
        periodName: periodName,
        amountDue: amountDue,
        icon: style.icon,
        color: style.color,
        backgroundColor: style.backgroundColor,
      );
    }

    return WarningViewModel(
      title: item.toString(),
      customerName: "",
      customerCode: "",
      phoneNumber: "",
      subscriberNumber: "",
      periodName: "",
      amountDue: "",
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
      backgroundColor: const Color(0xffFFF5F5),
    );
  }

  static String _buildTitle({
    required String collectionStatus,
    required String debtStatus,
    required String syncWarning,
    required String syncWarningNote,
  }) {
    if (syncWarningNote.isNotEmpty) {
      return syncWarningNote;
    }

    if (syncWarning == "INCONSISTENT") {
      return "Dữ liệu đối chiếu không khớp";
    }

    if (syncWarning == "COLLECTED_NOT_MARKED") {
      return "Đã thu nhưng chưa được đánh dấu";
    }

    if (collectionStatus == "DA_THANH_TOAN" && debtStatus == "CHUA_GACH_NO") {
      return "Đã thanh toán nhưng chưa gạch nợ";
    }

    return "Cảnh báo";
  }

  static _WarningStyle _buildStyle({
    required String collectionStatus,
    required String debtStatus,
    required String syncWarning,
  }) {
    if (syncWarning == "INCONSISTENT") {
      return const _WarningStyle(
        icon: Icons.error_outline,
        color: Colors.red,
        backgroundColor: Color(0xffFFF5F5),
      );
    }

    if (syncWarning == "COLLECTED_NOT_MARKED") {
      return const _WarningStyle(
        icon: Icons.sync_problem,
        color: Colors.deepOrange,
        backgroundColor: Color(0xffFFF3E0),
      );
    }

    if (collectionStatus == "DA_THANH_TOAN" && debtStatus == "CHUA_GACH_NO") {
      return const _WarningStyle(
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.orange,
        backgroundColor: Color(0xffFFF8F1),
      );
    }

    return const _WarningStyle(
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
      backgroundColor: Color(0xffFFF5F5),
    );
  }
}

class _WarningStyle {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _WarningStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
