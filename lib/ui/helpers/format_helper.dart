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
}
