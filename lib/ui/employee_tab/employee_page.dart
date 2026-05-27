import 'package:billing_app/models/employee.dart';
import 'package:billing_app/provider/employee_provider.dart';
import 'package:billing_app/ui/dialog/confirm_delete_dialog.dart';
import 'package:billing_app/ui/employee_tab/add_employee_page.dart';
import 'package:billing_app/ui/employee_tab/components/employee_list.dart';
import 'package:billing_app/ui/employee_tab/components/employee_search_bar.dart';
import 'package:billing_app/ui/employee_tab/components/empty_state.dart';
import 'package:billing_app/ui/employee_tab/employee_submit_data.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final TextEditingController searchController = TextEditingController();

  String keyword = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _formatMessage(dynamic message) {
    if (message == null) {
      return "Có lỗi xảy ra";
    }

    final text = message.toString();

    final regex = RegExp(r'message:\s*([^}\]]+)');

    final matches = regex
        .allMatches(text)
        .map((e) => e.group(1)?.trim())
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toList();

    if (matches.isNotEmpty) {
      return matches.join("\n");
    }

    return text;
  }

  Future<void> _openForm({Employee? emp}) async {
    final result = await Navigator.push<EmployeeSubmitData>(
      context,
      MaterialPageRoute(builder: (_) => AddEmployeePage(employee: emp)),
    );

    if (result == null) {
      return;
    }

    final provider = context.read<EmployeeProvider>();

    if (emp == null) {
      final addRes = await provider.addEmployee(
        result.employee,
        result.password!,
      );

      _showToast(addRes.success, addRes.message ?? "", provider);
    } else {
      final updateRes = await provider.updateEmployee(emp.id!, result.employee);

      _showToast(updateRes.success, updateRes.message ?? "", provider);
    }

    if (!mounted) return;

    await provider.fetchEmployees();
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: "Xoá nhân viên",
        message: "Bạn có chắc muốn xoá nhân viên '${employee.fullName}' không?",
      ),
    );

    if (confirm != true) {
      return;
    }

    final provider = context.read<EmployeeProvider>();

    final res = await provider.deleteEmployee(employee.id!);

    if (!mounted) {
      return;
    }

    if (res.success) {
      ToastUtils.success(
        context,
        message: _formatMessage(res.message ?? "Đã xoá thành công"),
      );
    } else {
      ToastUtils.error(
        context,
        message: _formatMessage(res.message ?? "Xoá thất bại"),
      );
    }
  }

  void _showToast(bool success, String message, EmployeeProvider provider) {
    final displayMessage = _formatMessage(
      message.isNotEmpty ? message : provider.error,
    );

    if (success) {
      ToastUtils.success(context, message: displayMessage);
    } else {
      ToastUtils.error(context, message: displayMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, p, _) {
        final filteredEmployees = p.employees.where((e) {
          final q = keyword.toLowerCase();

          return e.fullName.toLowerCase().contains(q) ||
              e.username.toLowerCase().contains(q) ||
              (e.phone ?? "").toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(title: const Text("Quản lý nhân viên")),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _openForm();
            },
            icon: const Icon(Icons.add),
            label: const Text("Thêm"),
          ),

          body: Stack(
            children: [
              Column(
                children: [
                  EmployeeSearchBar(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        keyword = value.trim();
                      });
                    },
                  ),

                  Expanded(
                    child: p.loading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredEmployees.isEmpty
                        ? const EmptyState()
                        : EmployeeList(
                            employees: filteredEmployees,
                            onEdit: (e) {
                              _openForm(emp: e);
                            },
                            onDelete: (e) {
                              _deleteEmployee(e);
                            },
                          ),
                  ),
                ],
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
