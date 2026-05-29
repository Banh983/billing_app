import 'package:flutter/material.dart';

import '../../../models/billing_period.dart';

class BillingPeriodCard extends StatelessWidget {
  final BillingPeriod billingPeriod;

  final VoidCallback onTap;
  final VoidCallback onClose;

  const BillingPeriodCard({
    super.key,
    required this.billingPeriod,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = billingPeriod.status == "CLOSED";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

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

      child: InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,

                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.grey.shade300
                          : Colors.red.shade50,

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Icon(
                      Icons.calendar_month,
                      size: 32,

                      color: isClosed ? Colors.grey : Colors.red,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          billingPeriod.name,

                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          isClosed
                              ? "Kỳ cước đã khóa dữ liệu"
                              : "Đang vận hành thu cước",

                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.grey.shade200
                          : Colors.red.shade50,

                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Text(
                      isClosed ? "ĐÃ ĐÓNG" : "ĐANG MỞ",

                      style: TextStyle(
                        color: isClosed ? Colors.grey : Colors.red,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.grey.shade50,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    buildItem("Tháng", "${billingPeriod.month}"),

                    const SizedBox(height: 12),

                    buildItem("Năm", "${billingPeriod.year}"),

                    const SizedBox(height: 12),

                    buildItem("Trạng thái", billingPeriod.status),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,

                      icon: const Icon(Icons.receipt_long),

                      label: const Text("Quản lý"),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,

                        side: BorderSide(color: Colors.red.shade200),

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isClosed ? null : onClose,

                      icon: Icon(isClosed ? Icons.lock : Icons.lock_open),

                      label: Text(isClosed ? "Đã đóng" : "Đóng kỳ"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,

                        foregroundColor: Colors.white,

                        disabledBackgroundColor: Colors.grey.shade300,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: TextStyle(color: Colors.grey.shade700)),
        ),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
