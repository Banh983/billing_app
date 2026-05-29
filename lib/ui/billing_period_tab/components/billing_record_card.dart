import 'package:flutter/material.dart';

import '../../../models/billing_record.dart';

class BillingRecordCard extends StatelessWidget {
  final BillingRecord record;

  final VoidCallback onTap;

  const BillingRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final paidColor = record.paid ? Colors.green : Colors.red;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.customerName,

                    style: const TextStyle(
                      fontSize: 22,

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
                    color: paidColor.withOpacity(0.1),

                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    record.paid ? "Đã thu" : "Chưa thu",

                    style: TextStyle(
                      color: paidColor,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            buildItem(Icons.phone, "SĐT", record.phone),

            buildItem(Icons.location_on, "Địa chỉ", record.address),

            buildItem(Icons.receipt_long, "Kỳ", record.billingPeriod),

            buildItem(Icons.wifi, "Dịch vụ", record.serviceType),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "${record.amount.toStringAsFixed(0)} VNĐ",

                    style: TextStyle(
                      fontSize: 24,

                      fontWeight: FontWeight.bold,

                      color: paidColor,
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {},

                  icon: Icon(record.paid ? Icons.receipt : Icons.payments),

                  label: Text(record.paid ? "Phiếu thu" : "Thu cước"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: paidColor,

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
        children: [
          Icon(icon, size: 18, color: Colors.red),

          const SizedBox(width: 10),

          SizedBox(
            width: 70,

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
}
