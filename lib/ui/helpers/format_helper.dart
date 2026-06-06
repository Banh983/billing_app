import 'package:intl/intl.dart';

class FormatHelper {
  // =========================
  // DATE TIME
  // =========================

  static String formatDateTime(dynamic date) {
    if (date == null || date.toString().trim().isEmpty) {
      return "Không có dữ liệu";
    }

    try {
      final parsedDate = DateTime.parse(date.toString()).toLocal();

      return DateFormat('HH:mm - dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date.toString();
    }
  }

  // =========================
  // DATE ONLY
  // =========================

  static String formatDate(dynamic date) {
    if (date == null || date.toString().trim().isEmpty) {
      return "Không có dữ liệu";
    }

    try {
      final parsedDate = DateTime.parse(date.toString()).toLocal();

      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date.toString();
    }
  }

  // =========================
  // TIME ONLY
  // =========================

  static String formatTime(dynamic date) {
    if (date == null || date.toString().trim().isEmpty) {
      return "Không có dữ liệu";
    }

    try {
      final parsedDate = DateTime.parse(date.toString()).toLocal();

      return DateFormat('HH:mm').format(parsedDate);
    } catch (e) {
      return date.toString();
    }
  }

  // =========================
  // MONEY
  // =========================

  static String formatMoney(num? amount) {
    if (amount == null) {
      return "0 đ";
    }

    return "${NumberFormat("#,###", "vi_VN").format(amount)} đ";
  }

  // =========================
  // MONEY NO UNIT
  // =========================

  static String formatMoneyOnly(num? amount) {
    if (amount == null) {
      return "0";
    }

    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  // =========================
  // BILL PRINT TIME
  // =========================

  static String formatBillPrintDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatBillPrintDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // =========================
  // ROLE
  // =========================

  static String formatRole(dynamic role) {
    if (role == null || role.toString().trim().isEmpty) {
      return "Không có dữ liệu";
    }

    switch (role.toString().toUpperCase()) {
      case "MANAGER":
        return "Quản lý";

      case "CONSULTANT":
        return "Nhân viên thu cước";

      case "ADMIN":
        return "Quản trị viên";

      default:
        return role.toString();
    }
  }

  // =========================
  // ACCOUNT STATUS
  // =========================

  static String formatAccountStatus(dynamic status) {
    if (status == null || status.toString().trim().isEmpty) {
      return "Không có dữ liệu";
    }

    switch (status.toString().toUpperCase()) {
      case "ACTIVE":
        return "Đang hoạt động";

      case "INACTIVE":
        return "Ngừng hoạt động";

      default:
        return status.toString();
    }
  }
  // =========================
  // COUNT BADGE
  // =========================

  static String formatCount(int? count, {int max = 99}) {
    if (count == null || count <= 0) {
      return "0";
    }

    return count > max ? "$max+" : count.toString();
  }
}
