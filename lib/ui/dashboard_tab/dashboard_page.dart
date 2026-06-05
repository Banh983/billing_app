import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dashboard_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/dashboard_provider.dart';

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
      final token = context.read<AuthProvider>().token ?? "";

      context.read<DashboardProvider>().fetchDashboard(token: token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final token = context.read<AuthProvider>().token ?? "";

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
          : provider.error != null
          ? _ErrorView(
              message: provider.error!,
              onRetry: () {
                provider.refresh(token);
              },
            )
          : RefreshIndicator(
              onRefresh: () => provider.refresh(token),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MonthYearFilter(provider: provider, token: token),
                  const SizedBox(height: 16),
                  if (provider.overview != null)
                    _OverviewSection(overview: provider.overview!),
                  const SizedBox(height: 16),
                  _ConsultantSection(consultants: provider.consultants),
                  const SizedBox(height: 16),
                  _DailyStatsSection(stats: provider.dailyStats),
                  const SizedBox(height: 16),
                  _WarningSection(warnings: provider.warnings),
                ],
              ),
            ),
    );
  }
}

class _MonthYearFilter extends StatelessWidget {
  final DashboardProvider provider;
  final String token;

  const _MonthYearFilter({required this.provider, required this.token});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: provider.selectedMonth,
            decoration: _decoration("Tháng"),
            items: List.generate(12, (index) {
              final month = index + 1;

              return DropdownMenuItem(
                value: month,
                child: Text("Tháng $month"),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                provider.fetchDashboard(
                  token: token,
                  month: value,
                  year: provider.selectedYear,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: provider.selectedYear,
            decoration: _decoration("Năm"),
            items: List.generate(5, (index) {
              final year = DateTime.now().year - index;

              return DropdownMenuItem(value: year, child: Text("$year"));
            }),
            onChanged: (value) {
              if (value != null) {
                provider.fetchDashboard(
                  token: token,
                  month: provider.selectedMonth,
                  year: value,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final DashboardOverviewModel overview;

  const _OverviewSection({required this.overview});

  @override
  Widget build(BuildContext context) {
    final remainRecords =
        overview.totalRecordsImported - overview.totalCollectedRecords;

    final remainAmount =
        overview.totalExpectedAmount - overview.totalCollectedAmount;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                title: "Đã import",
                value: "${overview.totalRecordsImported}",
                icon: Icons.upload_file,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                title: "Đã thu",
                value: "${overview.totalCollectedRecords}",
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                title: "Còn lại",
                value: "$remainRecords",
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                title: "Tiến độ",
                value: "${overview.progressPercentage.toStringAsFixed(1)}%",
                icon: Icons.trending_up,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tổng quan tiền thu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _MoneyRow(
                label: "Tổng phải thu",
                value: _formatMoney(overview.totalExpectedAmount),
              ),
              _MoneyRow(
                label: "Đã thu",
                value: _formatMoney(overview.totalCollectedAmount),
                color: Colors.green,
              ),
              _MoneyRow(
                label: "Còn lại",
                value: _formatMoney(remainAmount),
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (overview.progressPercentage / 100).clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsultantSection extends StatelessWidget {
  final List<ConsultantPerformanceModel> consultants;

  const _ConsultantSection({required this.consultants});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tiến độ nhân viên",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (consultants.isEmpty)
            const Text(
              "Chưa có dữ liệu nhân viên",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...consultants.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.consultantName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: item.progress.clamp(0, 1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${item.collectedRecords}/${item.targetRecords} hóa đơn",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${_formatMoney(item.collectedAmount)} / ${_formatMoney(item.targetAmount)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DailyStatsSection extends StatelessWidget {
  final List<ConsultantDailyStatsModel> stats;

  const _DailyStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thống kê hôm nay",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (stats.isEmpty)
            const Text(
              "Chưa có dữ liệu hôm nay",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...stats.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffffebee),
                  child: Icon(Icons.person, color: Colors.red),
                ),
                title: Text(
                  item.consultantName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  item.firstBillPrintedAt == null
                      ? "Chưa in bill hôm nay"
                      : "In bill đầu tiên: ${_formatDateTime(item.firstBillPrintedAt!)}",
                ),
                trailing: Text(
                  "${item.collectedCount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _WarningSection extends StatelessWidget {
  final List<dynamic> warnings;

  const _WarningSection({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cảnh báo hệ thống",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (warnings.isEmpty)
            const Text(
              "Không có cảnh báo",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...warnings.map((item) {
              final text = _getWarningText(item);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(text)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _getWarningText(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item["message"] ??
          item["title"] ??
          item["customerName"] ??
          item["customerCode"] ??
          item.toString();
    }

    return item.toString();
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MoneyRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Thử lại")),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value) {
  final text = value.toStringAsFixed(0);
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final indexFromEnd = text.length - i;

    buffer.write(text[i]);

    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(".");
    }
  }

  return "${buffer.toString()}đ";
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();

  final day = local.day.toString().padLeft(2, "0");
  final month = local.month.toString().padLeft(2, "0");
  final year = local.year.toString();

  final hour = local.hour.toString().padLeft(2, "0");
  final minute = local.minute.toString().padLeft(2, "0");

  return "$hour:$minute $day/$month/$year";
}
