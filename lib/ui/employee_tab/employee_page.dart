import 'package:billing_app/ui/employee_tab/components/employee_card.dart';
import 'package:billing_app/ui/employee_tab/components/employee_form_dialog.dart';
import 'package:billing_app/ui/employee_tab/components/empty_state.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/employee.dart';
import '../../provider/employee_provider.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  Future<void> _openForm({Employee? emp}) async {
    final result = await showDialog<Employee?>(
      context: context,
      builder: (_) => EmployeeFormDialog(employee: emp),
    );

    if (result == null) return;

    final provider = context.read<EmployeeProvider>();

    bool ok;

    if (emp == null) {
      final pass = await _showPasswordDialog();
      if (pass == null) return;

      ok = await provider.addEmployee(result, pass);
    } else {
      final id = emp.id!;

      final updateOk = await provider.updateEmployee(id, result);

      final statusOk = await provider.setStatus(id, result.status!);

      ok = updateOk && statusOk;
    }

    if (!mounted) return;

    final message = provider.error ?? provider.actionMessage ?? "";

    if (ok) {
      ToastUtils.success(
        context,
        message: message.isNotEmpty ? message : "Thành công",
      );
    } else {
      ToastUtils.error(
        context,
        message: message.isNotEmpty ? message : "Có lỗi xảy ra",
      );
    }

    provider.fetchEmployees();
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mật khẩu"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Nhập mật khẩu",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, p, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Quản lý nhân viên")),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text("Thêm"),
          ),

          body: Stack(
            children: [
              if (p.loading)
                const Center(child: CircularProgressIndicator())
              else if (p.employees.isEmpty)
                const EmptyState()
              else
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: p.employees.length,
                  itemBuilder: (_, i) {
                    final e = p.employees[i];

                    return EmployeeCard(
                      employee: e,
                      onEdit: () => _openForm(emp: e),
                      onDelete: () async {
                        final ok = await p.deleteEmployee(e.id!);

                        if (!context.mounted) return;

                        final message = p.error ?? p.actionMessage ?? "";

                        if (ok) {
                          ToastUtils.success(
                            context,
                            message: message.isNotEmpty
                                ? message
                                : "Đã xoá thành công",
                          );
                        } else {
                          ToastUtils.error(
                            context,
                            message: message.isNotEmpty
                                ? message
                                : "Xoá thất bại",
                          );
                        }
                      },
                    );
                  },
                ),

              if (p.actionLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
