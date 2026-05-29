import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/customer_provider.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailPage> createState() =>
      _CustomerDetailPageState();
}

class _CustomerDetailPageState
    extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CustomerProvider>()
          .getDetail(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<CustomerProvider>();

    final customer =
        provider.selectedCustomer;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết khách hàng"),
      ),
      body: provider.loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : customer == null
              ? const Center(
                  child:
                      Text("Không có dữ liệu"),
                )
              : ListView(
                  padding:
                      const EdgeInsets.all(16),
                  children: [
                    _item(
                      "Mã KH",
                      customer.customerCode,
                    ),
                    _item(
                      "Tên KH",
                      customer.customerName,
                    ),
                    _item(
                      "Thuê bao",
                      customer.subscriberNumber,
                    ),
                    _item(
                      "Điện thoại",
                      customer.phoneNumber,
                    ),
                    _item(
                      "Địa chỉ",
                      customer.fullAddress,
                    ),
                    _item(
                      "Kỳ cước",
                      customer.billingPeriodName,
                    ),
                    _item(
                      "Số tiền",
                      customer.amountDue
                          .toString(),
                    ),
                    _item(
                      "Đã thu",
                      customer.collectedAmount
                          .toString(),
                    ),
                    _item(
                      "Trạng thái",
                      customer.status,
                    ),
                    _item(
                      "Nhân viên",
                      customer
                          .assignedConsultantName,
                    ),
                  ],
                ),
    );
  }

  Widget _item(
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}