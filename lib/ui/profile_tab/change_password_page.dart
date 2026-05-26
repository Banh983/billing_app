import 'package:billing_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

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
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  // OLD PASSWORD
                  TextField(
                    controller: provider.oldPassController,

                    obscureText: true,

                    textInputAction: TextInputAction.next,

                    decoration: const InputDecoration(
                      labelText: "Mật khẩu cũ",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NEW PASSWORD
                  TextField(
                    controller: provider.newPassController,

                    obscureText: true,

                    textInputAction: TextInputAction.next,

                    decoration: const InputDecoration(
                      labelText: "Mật khẩu mới",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CONFIRM PASSWORD
                  TextField(
                    controller: provider.confirmPassController,

                    obscureText: true,

                    textInputAction: TextInputAction.done,

                    onSubmitted: (_) async {
                      await _handleChangePassword(context, provider);
                    },

                    decoration: const InputDecoration(
                      labelText: "Xác nhận mật khẩu",

                      prefixIcon: Icon(Icons.check),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
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
                              style: TextStyle(color: Colors.white),
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

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
        backgroundColor: result["success"] ? Colors.green : Colors.red,
      ),
    );

    if (result["success"]) {
      Navigator.pop(context);
    }
  }
}
