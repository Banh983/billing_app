import 'package:billing_app/ui/employee_tab/employee_submit_data.dart';
import 'package:billing_app/ui/helpers/custom_dropdown_field.dart';
import 'package:billing_app/ui/helpers/custom_input_field.dart';
import 'package:billing_app/ui/helpers/format_helper.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:flutter/material.dart';

import '../../../models/employee.dart';

class AddEmployeePage extends StatefulWidget {
  final Employee? employee;

  const AddEmployeePage({super.key, this.employee});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  late TextEditingController nameController;

  late TextEditingController usernameController;

  late TextEditingController phoneController;

  late TextEditingController passController;

  late TextEditingController confirmPassController;

  String role = "CONSULTANT";

  String status = "ACTIVE";

  bool get isEdit => widget.employee != null;

  static const primaryRed = Color(0xFFE53935);

  static const accentOrange = Color(0xFFFF7043);

  @override
  void initState() {
    super.initState();

    final e = widget.employee;

    nameController = TextEditingController(text: e?.fullName ?? "");

    usernameController = TextEditingController(text: e?.username ?? "");

    phoneController = TextEditingController(text: e?.phone ?? "");

    passController = TextEditingController();

    confirmPassController = TextEditingController();

    role = e?.role ?? "CONSULTANT";

    status = e?.status ?? "ACTIVE";
  }

  @override
  void dispose() {
    nameController.dispose();

    usernameController.dispose();

    phoneController.dispose();

    passController.dispose();

    confirmPassController.dispose();

    super.dispose();
  }

  void save() {
    // ======================
    // FULL NAME
    // ======================

    if (nameController.text.trim().isEmpty) {
      _showError("Vui lòng nhập họ tên");

      return;
    }

    // ======================
    // USERNAME
    // ======================

    if (usernameController.text.trim().isEmpty) {
      _showError("Vui lòng nhập username");

      return;
    }

    // ======================
    // PHONE VALIDATION
    // ======================

    final phone = phoneController.text.trim();

    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9]+$');

      if (!phoneRegex.hasMatch(phone)) {
        _showError("Số điện thoại chỉ được chứa chữ số");

        return;
      }

      if (phone.length != 10) {
        _showError("Số điện thoại phải gồm đúng 10 số");

        return;
      }
    }

    // ======================
    // PASSWORD
    // ======================

    if (!isEdit) {
      if (passController.text.trim().isEmpty) {
        _showError("Vui lòng nhập mật khẩu");

        return;
      }

      if (passController.text != confirmPassController.text) {
        _showError("Mật khẩu xác nhận không khớp");

        return;
      }
    }

    // ======================
    // RETURN DATA
    // ======================

    Navigator.pop(
      context,
      EmployeeSubmitData(
        password: isEdit ? null : passController.text.trim(),
        employee: Employee(
          id: widget.employee?.id,
          fullName: nameController.text.trim(),
          username: usernameController.text.trim(),
          phone: phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
          role: role,
          status: status,
        ),
      ),
    );
  }

  // ======================
  // TOAST ERROR
  // ======================

  void _showError(String msg) {
    ToastUtils.error(context, message: msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(isEdit ? "Cập nhật nhân viên" : "Thêm nhân viên"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [primaryRed, accentOrange]),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ======================
            // FULL NAME
            // ======================
            CustomInputField(
              controller: nameController,
              label: "Họ tên",
              icon: Icons.person,
            ),

            const SizedBox(height: 16),

            // ======================
            // USERNAME
            // ======================
            IgnorePointer(
              ignoring: isEdit,
              child: Opacity(
                opacity: isEdit ? 0.7 : 1,
                child: CustomInputField(
                  controller: usernameController,
                  label: "Username",
                  icon: Icons.account_circle,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ======================
            // PHONE
            // ======================
            CustomInputField(
              controller: phoneController,
              label: "Số điện thoại",
              icon: Icons.phone,
            ),

            // ======================
            // PASSWORD
            // ======================
            if (!isEdit) ...[
              const SizedBox(height: 16),

              CustomInputField(
                controller: passController,
                label: "Mật khẩu",
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 16),

              CustomInputField(
                controller: confirmPassController,
                label: "Xác nhận mật khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
            ],

            const SizedBox(height: 16),

            // ======================
            // ROLE
            // ======================
            CustomDropdownField(
              label: "Vai trò",
              icon: Icons.badge,
              value: role,
              items: [
                DropdownMenuItem(
                  value: "CONSULTANT",
                  child: Text(FormatHelper.formatRole("CONSULTANT")),
                ),
                DropdownMenuItem(
                  value: "MANAGER",
                  child: Text(FormatHelper.formatRole("MANAGER")),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;

                setState(() {
                  role = v;
                });
              },
            ),

            const SizedBox(height: 16),

            // ======================
            // STATUS
            // ======================
            CustomDropdownField(
              label: "Trạng thái",
              icon: Icons.circle,
              value: status,
              items: [
                DropdownMenuItem(
                  value: "ACTIVE",
                  child: Text(FormatHelper.formatAccountStatus("ACTIVE")),
                ),
                DropdownMenuItem(
                  value: "INACTIVE",
                  child: Text(FormatHelper.formatAccountStatus("INACTIVE")),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;

                setState(() {
                  status = v;
                });
              },
            ),

            const SizedBox(height: 30),

            // ======================
            // BUTTON
            // ======================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: save,
                child: Text(
                  isEdit ? "CẬP NHẬT NHÂN VIÊN" : "TẠO NHÂN VIÊN",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
