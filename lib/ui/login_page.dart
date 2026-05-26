import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final focusEmail = FocusNode();
  final focusPassword = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    focusEmail.dispose();
    focusPassword.dispose();
    super.dispose();
  }

  InputDecoration _input(String hint, IconData icon, bool focused) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.red),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    "assets/images/Viettel_login.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "HỆ THỐNG\nQUẢN LÝ THU CƯỚC",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      focusNode: focusEmail,
                      decoration: _input(
                        "Email",
                        Icons.email,
                        focusEmail.hasFocus,
                      ).copyWith(errorText: auth.emailError),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      focusNode: focusPassword,
                      obscureText: true,
                      decoration: _input(
                        "Mật khẩu",
                        Icons.lock,
                        focusPassword.hasFocus,
                      ).copyWith(errorText: auth.passwordError),
                    ),

                    if (auth.generalError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        auth.generalError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: auth.loading
                            ? null
                            : () async {
                                final ok = await auth.login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                if (!context.mounted) return;

                                if (ok) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HomePage(
                                        user: auth.user,
                                        token: auth.token ?? "",
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: auth.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "ĐĂNG NHẬP",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
