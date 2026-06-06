import 'package:flutter/material.dart';

import '../../../models/billing_record_model.dart';
import '../../helpers/format_helper.dart';

class HistoryCard extends StatelessWidget {
  final BillingRecordModel record;

  const HistoryCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xffe8f5e9),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  record.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                "Đã thu",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildItem(Icons.badge_outlined, "Mã KH", record.customerCode),
          _buildItem(Icons.phone, "SĐT", record.phoneNumber),
          _buildItem(Icons.receipt_long, "Thuê bao", record.subscriberNumber),
          _buildItem(Icons.calendar_month, "Kỳ cước", record.billingPeriodName),

          if (record.assignedConsultantName.isNotEmpty)
            _buildItem(Icons.person, "TVV", record.assignedConsultantName),

          const Divider(height: 24),

          Row(
            children: [
              const Text(
                "Số tiền đã thu",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                FormatHelper.formatMoney(record.amountDue),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.red),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : "-")),
        ],
      ),
    );
  }
}
