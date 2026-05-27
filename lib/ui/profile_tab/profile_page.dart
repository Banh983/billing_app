import 'package:billing_app/provider/auth_provider.dart';
import 'package:billing_app/ui/helpers/format_helper.dart';
import 'package:billing_app/ui/profile_tab/components/info_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'change_password_page.dart';
import '../login_page.dart';

class ProfilePage extends StatelessWidget {
  final dynamic user;
  final String token;

  const ProfilePage({super.key, required this.user, required this.token});

  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final String fullName = (user?.fullName ?? "").toString().trim();

    final String avatarLetter = fullName.isNotEmpty
        ? fullName[0].toUpperCase()
        : "U";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),

          child: Column(
            children: [
              // =========================
              // HEADER
              // =========================
              Container(
                width: double.infinity,

                padding: EdgeInsets.fromLTRB(24, 24, 24, size.height * 0.035),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFFF6B6B)],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(34),
                    bottomRight: Radius.circular(34),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Hồ sơ cá nhân",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Quản lý tài khoản thu cước Viettel",

                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),

                    const SizedBox(height: 28),

                    // =========================
                    // AVATAR
                    // =========================
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: Colors.white.withOpacity(0.18),

                          border: Border.all(color: Colors.white, width: 3),
                        ),

                        child: Center(
                          child: Text(
                            avatarLetter,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // USER INFO CARD
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      InfoTile(
                        icon: Icons.person_outline,
                        title: "Họ tên",
                        value: user?.fullName,
                      ),

                      const Divider(height: 28),

                      // =========================
                      // USERNAME
                      // =========================
                      InfoTile(
                        icon: Icons.account_circle_outlined,
                        title: "Username",
                        value: user?.username,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.phone_outlined,
                        title: "Số điện thoại",
                        value: user?.phone,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.badge_outlined,
                        title: "Vai trò",
                        value: user?.role,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.verified_user_outlined,
                        title: "Trạng thái tài khoản",
                        value: user?.status,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.calendar_today_outlined,
                        title: "Ngày tạo",
                        value: FormatHelper.formatDateTime(user?.createdAt),
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.update_outlined,
                        title: "Cập nhật",
                        value: FormatHelper.formatDateTime(user?.updatedAt),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // CHANGE PASSWORD CARD
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),

                    leading: Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: primaryRed.withOpacity(0.1),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(Icons.lock_outline, color: primaryRed),
                    ),

                    title: const Text(
                      "Đổi mật khẩu",

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: const Text("Cập nhật mật khẩu tài khoản"),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey,
                    ),

                    onTap: () {
                      context.read<AuthProvider>().clearPasswordFields();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =========================
              // LOGOUT BUTTON
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    icon: const Icon(Icons.logout, color: Colors.white),

                    label: const Text(
                      "Đăng xuất",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    onPressed: () {
                      context.read<AuthProvider>().logout();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
