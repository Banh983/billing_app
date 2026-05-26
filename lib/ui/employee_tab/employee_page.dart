import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/employee_provider.dart';
import '../../models/employee.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  Future<void> _openForm({Employee? emp}) async {
    final name = TextEditingController(text: emp?.fullName ?? "");
    final email = TextEditingController(text: emp?.email ?? "");
    final pass = TextEditingController(text: "");

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(emp == null ? "Thêm nhân viên" : "Cập nhật nhân viên"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Họ tên"),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            if (emp == null)
              TextField(
                controller: pass,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );

    if (result != true) return;

    final provider = context.read<EmployeeProvider>();

    final data = Employee(
      id: emp?.id,
      fullName: name.text.trim(),
      email: email.text.trim(),
      password: pass.text.trim(),
      role: "CONSULTANT",
      status: "ACTIVE",
    );

    if (emp == null) {
      await provider.addEmployee(data, pass.text.trim());
    } else {
      await provider.updateEmployee(emp.id!, data);
    }

    await provider.fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý nhân viên")),

      body: Consumer<EmployeeProvider>(
        builder: (context, p, _) {
          if (p.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (p.employees.isEmpty) {
            return const Center(child: Text("Không có nhân viên"));
          }

          return ListView.builder(
            itemCount: p.employees.length,
            itemBuilder: (_, i) {
              final e = p.employees[i];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(e.fullName),
                subtitle: Text("${e.email}\n${e.status ?? ''}"),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(emp: e),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await context.read<EmployeeProvider>().deleteEmployee(
                          e.id!,
                        );

                        await context.read<EmployeeProvider>().fetchEmployees();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
