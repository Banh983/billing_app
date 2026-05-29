import 'package:flutter/material.dart';

import '../../../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  final VoidCallback onTap;
  final VoidCallback onPrintBill;
  final VoidCallback onMarkDebt;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onPrintBill,
    required this.onMarkDebt,
  });

  Color get statusColor {
    switch (customer.status) {
      case "CHUA_THU":
        return Colors.orange;

      case "DA_IN_BILL":
        return Colors.blue;

      case "DA_GACH_NO":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              Text(customer.customerCode),

              Text(customer.subscriberNumber),

              Text(customer.fullAddress),

              const SizedBox(height: 10),

              Row(
                children: [
                  Chip(
                    label: Text(customer.status),
                    backgroundColor: statusColor.withOpacity(.2),
                  ),

                  const Spacer(),

                  Text("${customer.amountDue.toStringAsFixed(0)} đ"),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  if (customer.status == "CHUA_THU")
                    ElevatedButton(
                      onPressed: onPrintBill,
                      child: const Text("In bill"),
                    ),

                  if (customer.status == "DA_IN_BILL")
                    ElevatedButton(
                      onPressed: onMarkDebt,
                      child: const Text("Gạch nợ"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
