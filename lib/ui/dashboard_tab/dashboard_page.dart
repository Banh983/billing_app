import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../provider/dashboard_provider.dart';

import 'components/consultant_section.dart';
import 'components/daily_stats_section.dart';
import 'components/error_view.dart';
import 'components/month_year_filter.dart';
import 'components/overview_section.dart';
import 'components/warning_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color _dashboardBackgroundColor = Color(0xFFF5F5F5);
  static const Color _headerBackgroundColor = Colors.white;
  static const Color _primaryRed = Color(0xFFE53935);

  bool _canViewManagerDashboard(String role) {
    final normalizedRole = role.trim().toUpperCase();

    return normalizedRole == "MANAGER" || normalizedRole == "ADMIN";
  }

  /// Tự xác định icon trên status bar nên là sáng hay tối
  /// dựa theo độ sáng của màu nền.
  SystemUiOverlayStyle _buildSystemUiOverlayStyle(
    Color statusBarBackgroundColor,
  ) {
    final isLightBackground = statusBarBackgroundColor.computeLuminance() > 0.5;

    return SystemUiOverlayStyle(
      // Android có thể đặt màu nền trực tiếp.
      statusBarColor: statusBarBackgroundColor,

      // Android:
      // nền sáng -> icon tối
      // nền tối -> icon sáng
      statusBarIconBrightness: isLightBackground
          ? Brightness.dark
          : Brightness.light,

      // iOS dùng logic ngược với statusBarIconBrightness:
      // Brightness.light = nền sáng -> nội dung status bar tối
      // Brightness.dark = nền tối -> nội dung status bar sáng
      statusBarBrightness: isLightBackground
          ? Brightness.light
          : Brightness.dark,

      // Thanh điều hướng dưới Android
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,

      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final auth = context.read<AuthProvider>();

      final token = auth.token ?? "";
      final role = auth.user?.role ?? "";

      context.read<DashboardProvider>().fetchDashboard(
        token: token,
        role: role,
      );
    });
  }

  Widget _buildFixedLogo(double maxWidth) {
    final isSmallScreen = maxWidth < 390;

    return Container(
      width: double.infinity,
      color: _headerBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 20,
        14,
        isSmallScreen ? 16 : 20,
        12,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: isSmallScreen ? 26 : 30,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              height: 30,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardTitle(double maxWidth) {
    final isSmallScreen = maxWidth < 390;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Dashboard Thu Cước",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 27,
              fontWeight: FontWeight.w800,
              color: _primaryRed,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tổng quan hoạt động thu cước",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent({
    required DashboardProvider provider,
    required String token,
    required String role,
    required bool canViewManagerDashboard,
    required double maxWidth,
  }) {
    final horizontalPadding = maxWidth < 380 ? 12.0 : 16.0;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryRed));
    }

    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: () {
          provider.refresh(token, role);
        },
      );
    }

    return RefreshIndicator(
      color: _primaryRed,
      onRefresh: () => provider.refresh(token, role),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          24,
        ),
        children: [
          _buildDashboardTitle(maxWidth),

          const SizedBox(height: 14),

          MonthYearFilter(provider: provider, token: token, role: role),

          const SizedBox(height: 16),

          if (provider.overview != null)
            OverviewSection(overview: provider.overview!),

          if (canViewManagerDashboard) ...[
            const SizedBox(height: 16),

            ConsultantSection(consultants: provider.consultants),

            const SizedBox(height: 16),

            DailyStatsSection(stats: provider.dailyStats),

            const SizedBox(height: 16),

            WarningSection(warnings: provider.warnings),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    final auth = context.read<AuthProvider>();
    final token = auth.token ?? "";
    final role = auth.user?.role ?? "";

    final canViewManagerDashboard = _canViewManagerDashboard(role);

    /*
     * Đây là màu thực tế nằm phía sau thanh trạng thái.
     *
     * Hiện tại logo cố định có nền trắng nên giá trị là Colors.white.
     * Sau này đổi header sang màu đỏ, đen hoặc màu khác thì chỉ cần
     * đổi _headerBackgroundColor, màu icon status bar sẽ tự thay đổi.
     */
    final systemUiOverlayStyle = _buildSystemUiOverlayStyle(
      _headerBackgroundColor,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: _headerBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Logo được cố định, không cuộn theo nội dung.
                  _buildFixedLogo(constraints.maxWidth),

                  Expanded(
                    child: ColoredBox(
                      color: _dashboardBackgroundColor,
                      child: _buildDashboardContent(
                        provider: provider,
                        token: token,
                        role: role,
                        canViewManagerDashboard: canViewManagerDashboard,
                        maxWidth: constraints.maxWidth,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
