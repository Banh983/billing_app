import 'package:billing_app/models/employee.dart';
import 'package:billing_app/ui/helpers/custom_input_field.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final dynamic user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  static const primaryRed = Color(0xFFE53935);
  static const accentOrange = Color(0xFFFF7043);

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user?.fullName ?? "");
    phoneController = TextEditingController(text: widget.user?.phone ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void save() {
    if (nameController.text.trim().isEmpty) {
      ToastUtils.error(context, message: "Vui lòng nhập họ tên");
      return;
    }

    final phone = phoneController.text.trim();

    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9]+$');

      if (!phoneRegex.hasMatch(phone)) {
        ToastUtils.error(
          context,
          message: "Số điện thoại chỉ được chứa chữ số",
        );
        return;
      }

      if (phone.length != 10) {
        ToastUtils.error(context, message: "Số điện thoại phải gồm đúng 10 số");
        return;
      }
    }

    Navigator.pop(
      context,
      Employee(
        id: widget.user?.id,
        fullName: nameController.text.trim(),
        username: widget.user?.username ?? "",
        phone: phone.isEmpty ? null : phone,
        role: widget.user?.role ?? "CONSULTANT",
        status: widget.user?.status ?? "ACTIVE",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Sửa thông tin cá nhân"),
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
            CustomInputField(
              controller: nameController,
              label: "Họ tên",
              icon: Icons.person,
            ),

            const SizedBox(height: 16),

            CustomInputField(
              controller: phoneController,
              label: "Số điện thoại",
              icon: Icons.phone,
            ),

            const SizedBox(height: 30),

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
                child: const Text(
                  "LƯU THÔNG TIN",
                  style: TextStyle(
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
