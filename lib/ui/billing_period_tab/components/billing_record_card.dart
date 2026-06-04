import 'package:flutter/material.dart';

import '../../../models/billing_record_model.dart';
import '../../helpers/format_helper.dart';

class BillingRecordCard extends StatelessWidget {
  final BillingRecordModel record;
  final VoidCallback onTap;

  const BillingRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(record);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.customerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _getStatusText(record),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            buildItem(Icons.badge_outlined, "Mã KH", record.customerCode),

            buildItem(Icons.phone, "SĐT", record.phoneNumber),

            buildItem(Icons.receipt_long, "Thuê bao", record.subscriberNumber),

            buildItem(
              Icons.location_on,
              "Địa chỉ",
              record.fullAddress?.isNotEmpty == true
                  ? record.fullAddress!
                  : "-",
            ),

            buildItem(
              Icons.calendar_month,
              "Kỳ cước",
              record.billingPeriodName,
            ),

            if (record.assignedConsultantName.isNotEmpty)
              buildItem(Icons.person, "TVV", record.assignedConsultantName),

            buildItem(
              Icons.account_balance_wallet_outlined,
              "Gạch nợ",
              _getDebtStatusText(record),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    FormatHelper.formatMoney(record.amountDue),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility),
                  label: const Text("Chi tiết"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.red),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(BillingRecordModel record) {
    switch (record.collectionStatus) {
      case "DA_THANH_TOAN":
        return "Đã thanh toán";
      case "CHUA_THU":
        return "Chưa thu";
      default:
        return record.collectionStatus;
    }
  }

  String _getDebtStatusText(BillingRecordModel record) {
    switch (record.debtStatus) {
      case "DA_GACH_NO":
        return "Đã gạch nợ";
      case "CHUA_GACH_NO":
        return "Chưa gạch nợ";
      default:
        return record.debtStatus;
    }
  }

  Color _getStatusColor(BillingRecordModel record) {
    switch (record.collectionStatus) {
      case "DA_THANH_TOAN":
        return Colors.green;
      case "CHUA_THU":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
