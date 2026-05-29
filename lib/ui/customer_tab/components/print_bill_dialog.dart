import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/customer_model.dart';
import '../../../provider/customer_provider.dart';

class PrintBillDialog extends StatefulWidget {
  final CustomerModel customer;

  const PrintBillDialog({super.key, required this.customer});

  @override
  State<PrintBillDialog> createState() => _PrintBillDialogState();
}

class _PrintBillDialogState extends State<PrintBillDialog> {
  late final TextEditingController amountCtrl;

  @override
  void initState() {
    super.initState();

    amountCtrl = TextEditingController(
      text: widget.customer.amountDue.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thu tiền & In bill"),
      content: TextField(
        controller: amountCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: "Số tiền thu"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.read<CustomerProvider>().printBill(
              id: widget.customer.id,
              amount: double.tryParse(amountCtrl.text) ?? 0,
            );

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Xác nhận"),
        ),
      ],
    );
  }
}
