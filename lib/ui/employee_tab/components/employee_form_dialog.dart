import 'package:flutter/material.dart';
import '../../../models/employee.dart';

class EmployeeFormDialog extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormDialog({super.key, this.employee});

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  String role = "CONSULTANT";
  String status = "ACTIVE";

  @override
  void initState() {
    super.initState();

    final e = widget.employee;

    nameController = TextEditingController(text: e?.fullName ?? "");
    emailController = TextEditingController(text: e?.email ?? "");
    phoneController = TextEditingController(text: e?.phone ?? "");
    passwordController = TextEditingController();

    role = e?.role ?? "CONSULTANT";
    status = e?.status ?? "ACTIVE";
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

    return AlertDialog(
      title: Text(isEdit ? "Cập nhật nhân viên" : "Thêm nhân viên"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên *"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email *"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "SĐT"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(
                  value: "CONSULTANT",
                  child: Text("CONSULTANT"),
                ),
                DropdownMenuItem(value: "MANAGER", child: Text("MANAGER")),
              ],
              onChanged: (v) => setState(() => role = v!),
              decoration: const InputDecoration(labelText: "Role"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: "ACTIVE", child: Text("ACTIVE")),
                DropdownMenuItem(value: "INACTIVE", child: Text("INACTIVE")),
              ],
              onChanged: (v) => setState(() => status = v!),
              decoration: const InputDecoration(labelText: "Status"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Huỷ"),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty) {
              return;
            }

            Navigator.pop(
              context,
              Employee(
                id: widget.employee?.id,
                fullName: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                role: role,
                status: status,
              ),
            );
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}
