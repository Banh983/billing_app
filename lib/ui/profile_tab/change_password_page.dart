import 'package:billing_app/provider/auth_provider.dart';
import 'package:billing_app/ui/helpers/custom_input_field.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),

          appBar: AppBar(
            title: const Text("Đổi mật khẩu"),
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  Center(
                    child: Image.asset(
                      "assets/images/change_password.png",
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomInputField(
                    controller: provider.oldPassController,
                    label: "Mật khẩu cũ",
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 16),

                  CustomInputField(
                    controller: provider.newPassController,
                    label: "Mật khẩu mới",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 16),

                  CustomInputField(
                    controller: provider.confirmPassController,
                    label: "Xác nhận mật khẩu",
                    icon: Icons.check,
                    isPassword: true,
                    onSubmitted: (_) async {
                      await _handleChangePassword(context, provider);
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: provider.isChangingPassword
                          ? null
                          : () async {
                              await _handleChangePassword(context, provider);
                            },

                      child: provider.isChangingPassword
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Cập nhật mật khẩu",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleChangePassword(
    BuildContext context,
    AuthProvider provider,
  ) async {
    final result = await provider.changePassword();

    if (!context.mounted) return;

    final success = result["success"] == true;
    final message = result["message"] ?? "Có lỗi xảy ra";

    if (success) {
      Navigator.pop(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastUtils.success(context, message: message);
      });
    } else {
      ToastUtils.error(context, message: message);
    }
  }
}
