import 'package:flutter/material.dart';

import '../../helpers/format_helper.dart';

class WarningCard extends StatelessWidget {
  final dynamic item;
  final bool compact;

  const WarningCard({super.key, required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final warning = WarningViewModel.fromDynamic(item);

    return Container(
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

          if (warning.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                warning.message,
                style: const TextStyle(height: 1.35),
              ),
            ),

          if (warning.amountDue.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            width: 78,
            child: Text(
              label,
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
  final String message;
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
    required this.message,
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
      final status =
          item["status"]?.toString() ??
          item["collectionStatus"]?.toString() ??
          item["debtStatus"]?.toString() ??
          "";

      final customerName = item["customerName"]?.toString() ?? "Khách hàng";
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

      if (status == "DA_IN_BILL" || status == "DA_THANH_TOAN") {
        return WarningViewModel(
          title: "Đã thu nhưng chưa gạch nợ",
          message: "",
          customerName: customerName,
          customerCode: customerCode,
          phoneNumber: phoneNumber,
          subscriberNumber: subscriberNumber,
          periodName: periodName,
          amountDue: amountDue,
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.orange,
          backgroundColor: const Color(0xffFFF8F1),
        );
      }

      if (status == "INCONSISTENT") {
        return WarningViewModel(
          title: "Dữ liệu không khớp",
          message: "Vui lòng kiểm tra lại thông tin đối chiếu của hóa đơn này.",
          customerName: customerName,
          customerCode: customerCode,
          phoneNumber: phoneNumber,
          subscriberNumber: subscriberNumber,
          periodName: periodName,
          amountDue: amountDue,
          icon: Icons.error_outline,
          color: Colors.red,
          backgroundColor: const Color(0xffFFF5F5),
        );
      }

      return WarningViewModel(
        title: item["title"]?.toString() ?? "Cảnh báo",
        message: item["message"]?.toString() ?? "",
        customerName: customerName,
        customerCode: customerCode,
        phoneNumber: phoneNumber,
        subscriberNumber: subscriberNumber,
        periodName: periodName,
        amountDue: amountDue,
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        backgroundColor: const Color(0xffFFF5F5),
      );
    }

    return WarningViewModel(
      title: "Cảnh báo",
      message: item.toString(),
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
}
