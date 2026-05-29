import 'package:billing_app/ui/customer_tab/add_customer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/customer_provider.dart';

import 'customer_detail_page.dart';

import 'components/customer_card.dart';
import 'components/empty_state.dart';
import 'components/print_bill_dialog.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ khách hàng")),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Thêm KH"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerPage()),
          );

          if (result == true) {
            provider.fetchCustomers();
          }
        },
      ),

      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Mã KH, tên KH, SĐT, thuê bao...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();

                    provider.setSearch("");
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: provider.setSearch,
            ),
          ),

          /// FILTER STATUS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: provider.status.isEmpty ? null : provider.status,
              decoration: const InputDecoration(
                labelText: "Trạng thái",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "CHUA_THU", child: Text("Chưa thu")),
                DropdownMenuItem(
                  value: "DA_IN_BILL",
                  child: Text("Đã in bill"),
                ),
                DropdownMenuItem(
                  value: "DA_GACH_NO",
                  child: Text("Đã gạch nợ"),
                ),
              ],
              onChanged: (value) {
                provider.setStatus(value ?? "");
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.customers.isEmpty
                ? const EmptyState()
                : RefreshIndicator(
                    onRefresh: provider.fetchCustomers,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: provider.customers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final customer = provider.customers[index];

                        return CustomerCard(
                          customer: customer,

                          /// DETAIL
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomerDetailPage(customerId: customer.id),
                              ),
                            );
                          },

                          /// PRINT BILL
                          onPrintBill: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  PrintBillDialog(customer: customer),
                            );
                          },

                          /// MARK DEBT
                          onMarkDebt: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Xác nhận"),
                                content: const Text("Gạch nợ khách hàng này?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Huỷ"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Đồng ý"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) {
                              return;
                            }

                            try {
                              await provider.markDebt(customer.id);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Gạch nợ thành công"),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
