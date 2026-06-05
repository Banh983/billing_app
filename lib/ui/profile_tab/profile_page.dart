import 'package:billing_app/models/employee.dart';
import 'package:billing_app/provider/auth_provider.dart';
import 'package:billing_app/provider/employee_provider.dart';
import 'package:billing_app/ui/helpers/format_helper.dart';
import 'package:billing_app/ui/helpers/toast_utils.dart';
import 'package:billing_app/ui/profile_tab/bluetooth_printer_page.dart';
import 'package:billing_app/ui/profile_tab/components/action_card.dart';
import 'package:billing_app/ui/profile_tab/components/info_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'change_password_page.dart';
import 'edit_profile_page.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  final dynamic user;
  final String token;
  final Function(Employee updatedUser)? onUserUpdated;

  const ProfilePage({
    super.key,
    required this.user,
    required this.token,
    this.onUserUpdated,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const primaryRed = Color(0xFFE53935);

  late String fullName;
  late String username;
  late String phone;
  late String role;
  late String status;
  late String? createdAt;
  late String? updatedAt;

  @override
  void initState() {
    super.initState();
    _setUser(widget.user);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user != widget.user) {
      _setUser(widget.user);
    }
  }

  void _setUser(dynamic user) {
    fullName = user?.fullName ?? "";
    username = user?.username ?? "";
    phone = user?.phone ?? "";
    role = user?.role ?? "";
    status = user?.status ?? "";
    createdAt = user?.createdAt;
    updatedAt = user?.updatedAt;
  }

  Future<void> openEditProfile() async {
    final Employee? updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: widget.user)),
    );

    if (updatedData == null) return;

    if (updatedData.id == null) {
      ToastUtils.error(context, message: "Không tìm thấy ID tài khoản");
      return;
    }

    final result = await context.read<EmployeeProvider>().updateEmployee(
      updatedData.id!,
      updatedData,
    );

    if (!mounted) return;

    if (!result.success) {
      ToastUtils.error(
        context,
        message: result.message ?? "Cập nhật thông tin thất bại",
      );
      return;
    }

    final Employee updatedUser = result.data ?? updatedData;

    setState(() {
      _setUser(updatedUser);
    });

    widget.onUserUpdated?.call(updatedUser);

    ToastUtils.success(
      context,
      message: result.message ?? "Cập nhật thông tin thành công",
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final String avatarLetter = fullName.trim().isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : "U";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
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
                        value: fullName,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.account_circle_outlined,
                        title: "Username",
                        value: username,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.phone_outlined,
                        title: "Số điện thoại",
                        value: phone,
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.badge_outlined,
                        title: "Vai trò",
                        value: FormatHelper.formatRole(role),
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.verified_user_outlined,
                        title: "Trạng thái tài khoản",
                        value: FormatHelper.formatAccountStatus(status),
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.calendar_today_outlined,
                        title: "Ngày tạo",
                        value: FormatHelper.formatDateTime(createdAt),
                      ),

                      const Divider(height: 28),

                      InfoTile(
                        icon: Icons.update_outlined,
                        title: "Cập nhật",
                        value: FormatHelper.formatDateTime(updatedAt),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionCard(
                  icon: Icons.edit_outlined,
                  iconColor: Colors.green,
                  title: "Sửa thông tin cá nhân",
                  subtitle: "Cập nhật họ tên và số điện thoại",
                  onTap: openEditProfile,
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionCard(
                  icon: Icons.lock_outline,
                  iconColor: primaryRed,
                  title: "Đổi mật khẩu",
                  subtitle: "Cập nhật mật khẩu tài khoản",
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

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionCard(
                  icon: Icons.print,
                  iconColor: Colors.blue,
                  title: "Máy in Bluetooth",
                  subtitle: "Kết nối máy in bill cầm tay",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BluetoothPrinterPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

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
