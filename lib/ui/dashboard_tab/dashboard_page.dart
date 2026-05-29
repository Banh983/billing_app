import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/billing_period_provider.dart';
import '../billing_period_tab/billing_period_detail_page.dart';
import '../billing_period_tab/billing_period_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BillingPeriodProvider>().fetchBillingPeriods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillingPeriodProvider>();
    final periods = provider.periods;

    final latest = periods.isNotEmpty ? periods.first : null;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text(
          "Dashboard Thu Cước",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0,
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.fetchBillingPeriods,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// =========================
                  /// 1. KPI OVERVIEW (MOCK - sau này replace API)
                  /// =========================
                  _buildKPI(),

                  const SizedBox(height: 16),

                  /// =========================
                  /// 2. ALERT SECTION (QUAN TRỌNG NHẤT)
                  /// =========================
                  _buildAlertSection(),

                  const SizedBox(height: 16),

                  /// =========================
                  /// 3. CURRENT PERIOD
                  /// =========================
                  if (latest != null) _buildCurrentPeriod(latest, context),

                  const SizedBox(height: 16),

                  /// =========================
                  /// 4. RECENT PERIODS
                  /// =========================
                  _buildRecentPeriods(periods, context),

                  const SizedBox(height: 16),

                  /// =========================
                  /// 5. QUICK ACTIONS
                  /// =========================
                  _buildQuickActions(context),
                ],
              ),
            ),
    );
  }

  // =========================================================
  // KPI SECTION
  // =========================================================
  Widget _buildKPI() {
    return Row(
      children: [
        Expanded(child: _kpiCard("Đã thu", "1.2B", Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _kpiCard("Chưa thu", "320M", Colors.orange)),
      ],
    );
  }

  Widget _kpiCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ALERT SECTION (CORE BUSINESS VALUE)
  // =========================================================
  Widget _buildAlertSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Cảnh báo hệ thống",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          _AlertItem(
            icon: Icons.warning,
            text: "Bill đã in nhưng chưa gạch nợ: 32",
          ),
          _AlertItem(
            icon: Icons.sync_problem,
            text: "Dữ liệu Viettel chưa đồng bộ: 5",
          ),
          _AlertItem(
            icon: Icons.timelapse,
            text: "Khách hàng chưa cập nhật trạng thái: 12",
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CURRENT PERIOD
  // =========================================================
  Widget _buildCurrentPeriod(dynamic period, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kỳ cước hiện tại", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 8),

          Text(
            period.name ?? "Unknown",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _status(period.status ?? "UNKNOWN"),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BillingPeriodDetailPage(period: period),
                    ),
                  );
                },
                child: const Text("Chi tiết"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RECENT PERIODS
  // =========================================================
  Widget _buildRecentPeriods(List periods, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kỳ cước gần đây",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...periods.take(5).map((p) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(p.name ?? ""),
              subtitle: Text(p.status ?? ""),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BillingPeriodDetailPage(period: p),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thao tác nhanh",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _action(Icons.list, "Kỳ cước", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BillingPeriodPage()),
                );
              }),

              const SizedBox(width: 12),

              _action(Icons.refresh, "Làm mới", () {
                context.read<BillingPeriodProvider>().fetchBillingPeriods();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STATUS CHIP
  // =========================================================
  Widget _status(String status) {
    Color color;

    switch (status) {
      case "OPEN":
        color = Colors.green;
        break;
      case "CLOSED":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

// =========================================================
// ALERT ITEM WIDGET
// =========================================================
class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AlertItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
