import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class ToastUtils {
  // =========================
  // THEME HELPERS
  // =========================
  static Color _bg(BuildContext context) =>
      Theme.of(context).colorScheme.inverseSurface;

  static Color _fg(BuildContext context) =>
      Theme.of(context).colorScheme.onInverseSurface;

  static TextStyle _titleStyle(BuildContext context) =>
      TextStyle(color: _fg(context), fontWeight: FontWeight.bold, fontSize: 16);

  static TextStyle _msgStyle(BuildContext context) =>
      TextStyle(color: _fg(context).withOpacity(0.85), fontSize: 14);

  static BorderRadius get _radius => BorderRadius.circular(12);

  // =========================
  // BASE TOAST
  // =========================
  static Flushbar _base(
    BuildContext context, {
    required Widget icon,
    required String title,
    required String message,
    Duration? duration,
    Widget? trailing,
  }) {
    return Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: _radius,
      backgroundColor: _bg(context),
      duration: duration ?? const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.BOTTOM,
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: _titleStyle(context)),
                const SizedBox(height: 2),
                Text(message, style: _msgStyle(context)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
      icon: icon,
    );
  }

  // =========================
  // SUCCESS
  // =========================
  static void success(BuildContext context, {required String message}) {
    _base(
      context,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      title: "Thành công",
      message: message,
    ).show(context);
  }

  // =========================
  // ERROR
  // =========================
  static void error(BuildContext context, {required String message}) {
    _base(
      context,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      title: "Lỗi",
      message: message,
    ).show(context);
  }

  // =========================
  // INFO
  // =========================
  static void info(BuildContext context, {required String message}) {
    _base(
      context,
      icon: const Icon(Icons.info_outline, color: Colors.blue),
      title: "Thông tin",
      message: message,
    ).show(context);
  }

  // =========================
  // WARNING
  // =========================
  static void warning(BuildContext context, {required String message}) {
    _base(
      context,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: "Cảnh báo",
      message: message,
    ).show(context);
  }

  // =========================
  // FROM EXCEPTION (backend / API error)
  // =========================
  static void fromException(BuildContext context, Object e) {
    final msg = e.toString().replaceAll("Exception:", "").trim();

    error(context, message: msg);
  }

  // =========================
  // QUICK HELPERS (OPTIONAL)
  // =========================
  static void apiError(BuildContext context, String message) {
    error(context, message: message);
  }

  static void apiSuccess(BuildContext context, String message) {
    success(context, message: message);
  }
}
