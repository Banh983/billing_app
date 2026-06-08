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

      if (!mounted) return;

      _showToast(addRes.success, addRes.message ?? "", provider);
    } else {
      final updateRes = await provider.updateEmployee(emp.id!, result.employee);

      if (!mounted) return;

      _showToast(updateRes.success, updateRes.message ?? "", provider);
    }
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

  Future<void> _search(String value) async {
    keyword = value.trim();

    await context.read<EmployeeProvider>().fetchEmployees(
      page: 0,
      keywordValue: keyword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, p, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Quản lý nhân viên"),
            actions: [
              IconButton(
                onPressed: () {
                  _openForm();
                },
                icon: const Icon(Icons.add),
                tooltip: "Thêm nhân viên",
              ),
            ],
          ),

          body: Stack(
            children: [
              Column(
                children: [
                  EmployeeSearchBar(
                    controller: searchController,
                    onChanged: _search,
                  ),

                  Expanded(
                    child: p.loading
                        ? const Center(child: CircularProgressIndicator())
                        : p.employees.isEmpty
                        ? const EmptyState()
                        : EmployeeList(
                            employees: p.employees,
                            onEdit: (e) {
                              _openForm(emp: e);
                            },
                            onDelete: (e) {
                              _deleteEmployee(e);
                            },
                          ),
                  ),

                  _EmployeePaginationBar(provider: p),
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

class _EmployeePaginationBar extends StatelessWidget {
  final EmployeeProvider provider;

  const _EmployeePaginationBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: provider.hasPreviousPage
                  ? provider.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),

            ..._buildPages(context),

            IconButton(
              onPressed: provider.hasNextPage ? provider.nextPage : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages(BuildContext context) {
    final current = provider.currentPage + 1;
    final total = provider.totalPages;

    List<Widget> widgets = [];

    for (int page = 1; page <= total; page++) {
      if (page == 1 ||
          page == total ||
          (page >= current - 1 && page <= current + 1)) {
        widgets.add(_pageButton(page));
      } else if (page == current - 2 || page == current + 2) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text("..."),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _pageButton(int page) {
    final selected = page == provider.currentPage + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          provider.goToPage(page - 1);
        },
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE53935) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
