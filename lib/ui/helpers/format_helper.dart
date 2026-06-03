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
}
