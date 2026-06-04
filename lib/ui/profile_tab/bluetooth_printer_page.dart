// ============================================================
// FILE: bluetooth_printer_page.dart
// In tiếng Việt qua Bluetooth — dùng TCVN3 (ABC) encoding
// TCVN3: mỗi ký tự tiếng Việt = 1 byte duy nhất, không combining
// ESC t=0 (PC437/default) — máy dùng font TCVN3 built-in
// ============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

// ─── TCVN3 encoding table ─────────────────────────────────────
// Mỗi ký tự tiếng Việt → 1 byte duy nhất (0x80–0xFF)
// Không dùng combining diacritics như CP1258
const Map<int, int> _tcvn3 = {
  // ── Chữ hoa ──
  0x00C0: 0xC0, // À
  0x00C1: 0xC1, // Á
  0x00C3: 0xC3, // Ã  (dùng lại cho ể bên dưới — tách riêng)
  0x00C8: 0xC8, // È
  0x00C9: 0xC9, // É
  0x00CC: 0xCC, // Ì
  0x00CD: 0xCD, // Í
  0x00D2: 0xD2, // Ò
  0x00D3: 0xD3, // Ó
  0x00D5: 0xD5, // Õ
  0x00D9: 0xD9, // Ù
  0x00DA: 0xDA, // Ú
  0x00DD: 0xDD, // Ý
  // Ă Â Đ Ơ Ư
  0x0102: 0x80, // Ă
  0x00C2: 0xC2, // Â
  0x00CA: 0xCA, // Ê
  0x00D4: 0xD4, // Ô
  0x0110: 0x81, // Đ
  0x01A0: 0x82, // Ơ
  0x01AF: 0x83, // Ư
  // Ắ Ặ Ẳ Ẵ Ằ
  0x1EAE: 0x84, // Ắ
  0x1EB6: 0x85, // Ặ
  0x1EB2: 0x86, // Ẳ
  0x1EB4: 0x87, // Ẵ
  0x1EB0: 0x88, // Ằ
  // Ấ Ậ Ẩ Ẫ Ầ
  0x1EA4: 0x89, // Ấ
  0x1EAC: 0x8A, // Ậ
  0x1EA8: 0x8B, // Ẩ
  0x1EAA: 0x8C, // Ẫ
  0x1EA6: 0x8D, // Ầ
  // Ế Ệ Ể Ễ Ề
  0x1EBE: 0x8E, // Ế
  0x1EC6: 0x8F, // Ệ
  0x1EC2: 0x90, // Ể
  0x1EC4: 0x91, // Ễ
  0x1EC0: 0x92, // Ề
  // Ố Ộ Ổ Ỗ Ồ
  0x1ED0: 0x93, // Ố
  0x1ED8: 0x94, // Ộ
  0x1ED4: 0x95, // Ổ
  0x1ED6: 0x96, // Ỗ
  0x1ED2: 0x97, // Ồ
  // Ớ Ợ Ở Ỡ Ờ
  0x1EDA: 0x98, // Ớ
  0x1EE2: 0x99, // Ợ
  0x1EDE: 0x9A, // Ở
  0x1EE0: 0x9B, // Ỡ
  0x1EDC: 0x9C, // Ờ
  // Ứ Ự Ử Ữ Ừ
  0x1EE8: 0x9D, // Ứ
  0x1EF0: 0x9E, // Ự
  0x1EEC: 0x9F, // Ử
  0x1EEE: 0xA0, // Ữ
  0x1EEA: 0xA1, // Ừ
  // Ạ Ả Ẹ Ẻ Ị Ỉ Ọ Ỏ Ụ Ủ Ỵ Ỷ Ẽ Ĩ
  0x1EA0: 0xA2, // Ạ
  0x1EA2: 0xA3, // Ả
  0x1EB8: 0xA4, // Ẹ
  0x1EBA: 0xA5, // Ẻ
  0x1ECA: 0xA6, // Ị
  0x1EC8: 0xA7, // Ỉ
  0x1ECC: 0xA8, // Ọ
  0x1ECE: 0xA9, // Ỏ
  0x1EE4: 0xAA, // Ụ
  0x1EE6: 0xAB, // Ủ
  0x1EF4: 0xAC, // Ỵ
  0x1EF6: 0xAD, // Ỷ
  0x1EBC: 0xAE, // Ẽ
  0x0128: 0xAF, // Ĩ
  // ── Chữ thường ──
  0x00E0: 0xE0, // à
  0x00E1: 0xE1, // á
  0x00E2: 0xE2, // â
  0x00E3: 0xE3, // ã
  0x00E8: 0xE8, // è
  0x00E9: 0xE9, // é
  0x00EA: 0xEA, // ê
  0x00EC: 0xEC, // ì
  0x00ED: 0xED, // í
  0x00F2: 0xF2, // ò
  0x00F3: 0xF3, // ó
  0x00F4: 0xF4, // ô
  0x00F5: 0xF5, // õ
  0x00F9: 0xF9, // ù
  0x00FA: 0xFA, // ú
  0x00FD: 0xFD, // ý
  // ă â đ ơ ư
  0x0103: 0xB0, // ă
  0x0111: 0xB1, // đ
  0x01A1: 0xB2, // ơ
  0x01B0: 0xB3, // ư
  // ắ ặ ẳ ẵ ằ
  0x1EAF: 0xB4, // ắ
  0x1EB7: 0xB5, // ặ
  0x1EB3: 0xB6, // ẳ
  0x1EB5: 0xB7, // ẵ
  0x1EB1: 0xB8, // ằ
  // ấ ậ ẩ ẫ ầ
  0x1EA5: 0xB9, // ấ
  0x1EAD: 0xBA, // ậ
  0x1EA9: 0xBB, // ẩ
  0x1EAB: 0xBC, // ẫ
  0x1EA7: 0xBD, // ầ
  // ế ệ
  0x1EBF: 0xBE, // ế
  0x1EC7: 0xBF, // ệ
  // ể ễ ề
  0x1EC3: 0xC3, // ể
  0x1EC5: 0xC4, // ễ
  0x1EC1: 0xC5, // ề
  // ố ộ
  0x1ED1: 0xC6, // ố
  0x1ED9: 0xC7, // ộ
  // ổ ỗ ồ
  0x1ED5: 0xCB, // ổ
  0x1ED7: 0xCF, // ỗ
  0x1ED3: 0xD0, // ồ
  // ớ
  0x1EDB: 0xD1, // ớ
  // ợ ở ỡ ờ
  0x1EE3: 0xD6, // ợ
  0x1EDF: 0xD7, // ở
  0x1EE1: 0xD8, // ỡ
  0x1EDD: 0xDB, // ờ
  // ứ
  0x1EE9: 0xDC, // ứ
  // ự ử ữ ừ
  0x1EF1: 0xDE, // ự
  0x1EED: 0xDF, // ử
  0x1EEF: 0xE4, // ữ
  0x1EEB: 0xE5, // ừ
  // ạ ả
  0x1EA1: 0xE6, // ạ
  0x1EA3: 0xE7, // ả
  // ẹ ẻ
  0x1EB9: 0xEB, // ẹ
  0x1EBB: 0xEE, // ẻ
  // ị ỉ
  0x1ECB: 0xEF, // ị
  0x1EC9: 0xF0, // ỉ
  // ọ ỏ
  0x1ECD: 0xF1, // ọ
  0x1ECF: 0xF6, // ỏ
  // ụ ủ
  0x1EE5: 0xF7, // ụ
  0x1EE7: 0xF8, // ủ
  // ỵ ỷ ỹ
  0x1EF5: 0xFB, // ỵ
  0x1EF7: 0xFC, // ỷ
  0x1EF9: 0xFF, // ỹ
  // ẽ ĩ
  0x1EBD: 0xFE, // ẽ
  0x0129: 0xFF, // ĩ
  // ỳ
  0x1EF3: 0xF2, // ỳ (approximate: dùng ò)
};

/// Encode chuỗi Unicode → TCVN3 bytes
/// Mỗi ký tự tiếng Việt → đúng 1 byte (0x80–0xFF)
List<int> encodeTCVN3(String s) {
  final out = <int>[];
  for (final rune in s.runes) {
    if (rune < 0x80) {
      out.add(rune);
    } else {
      out.add(_tcvn3[rune] ?? 0x3F); // '?' nếu không có trong bảng
    }
  }
  return out;
}

// ─── Lệnh ESC/POS ────────────────────────────────────────────
List<int> escInit() => [0x1B, 0x40];
List<int> escR(int n) => [0x1B, 0x52, n];
List<int> escT(int n) => [0x1B, 0x74, n];
List<int> escCenter() => [0x1B, 0x61, 0x01];
List<int> escLeft() => [0x1B, 0x61, 0x00];
List<int> escBold(bool on) => [0x1B, 0x45, on ? 1 : 0];
List<int> escCut() => [0x1D, 0x56, 0x41, 0x10];

List<int> asciiLine(String s) => [...s.codeUnits, 0x0A];
List<int> vietLine(String s) => [...encodeTCVN3(s), 0x0A];
List<int> hrLine() => asciiLine('--------------------------------');

// ─── Widget chính ────────────────────────────────────────────
class BluetoothPrinterPage extends StatefulWidget {
  const BluetoothPrinterPage({super.key});

  @override
  State<BluetoothPrinterPage> createState() => _BluetoothPrinterPageState();
}

class _BluetoothPrinterPageState extends State<BluetoothPrinterPage> {
  List<BluetoothInfo> devices = [];
  BluetoothInfo? selectedDevice;
  bool isLoading = false;
  bool isPrinting = false;
  String _log = '';

  void _setLog(String msg) {
    debugPrint('[Printer] $msg');
    if (mounted) setState(() => _log = msg);
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;
    final perms = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ];
    _setLog('Đang xin quyền...');
    final statuses = await perms.request();
    final denied = statuses.entries
        .where(
          (e) =>
              e.value == PermissionStatus.denied ||
              e.value == PermissionStatus.permanentlyDenied,
        )
        .toList();
    if (denied.isEmpty) {
      _setLog('Đủ quyền ✓');
      return true;
    }
    final hasPermanent = denied.any(
      (e) => e.value == PermissionStatus.permanentlyDenied,
    );
    if (hasPermanent && mounted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cần quyền Bluetooth'),
          content: const Text(
            'Vào Cài đặt → Quyền ứng dụng → bật Bluetooth và Vị trí.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Mở Cài đặt'),
            ),
          ],
        ),
      );
      if (open == true) await openAppSettings();
      return false;
    }
    _setLog('Thiếu quyền');
    return false;
  }

  Future<void> loadDevices() async {
    setState(() {
      isLoading = true;
      devices = [];
    });
    if (!await _requestPermissions()) {
      setState(() => isLoading = false);
      return;
    }
    final btEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!btEnabled) {
      _setLog('Bluetooth chưa bật');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text('Vui lòng bật Bluetooth'),
          ),
        );
      setState(() => isLoading = false);
      return;
    }
    try {
      _setLog('Đang tìm...');
      final paired = await PrintBluetoothThermal.pairedBluetooths;
      if (paired.isEmpty) {
        _setLog('Không tìm thấy máy in');
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                'Chưa ghép đôi máy in. Vào Cài đặt → Bluetooth → ghép đôi trước.',
              ),
            ),
          );
      } else {
        _setLog('Tìm thấy ${paired.length} thiết bị');
        setState(() => devices = paired);
      }
    } catch (e) {
      _setLog('Lỗi: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> connectPrinter(BluetoothInfo device) async {
    _setLog('Đang kết nối ${device.name}...');
    final wasConn = await PrintBluetoothThermal.connectionStatus;
    if (wasConn) {
      await PrintBluetoothThermal.disconnect;
      await Future.delayed(const Duration(milliseconds: 400));
    }
    bool connected = false;
    for (int i = 1; i <= 3; i++) {
      _setLog('Kết nối lần $i/3...');
      try {
        connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress,
        );
      } catch (e) {
        _setLog('Lần $i lỗi: $e');
      }
      if (connected) break;
      await Future.delayed(const Duration(milliseconds: 700));
    }
    if (!connected) {
      _setLog('Kết nối thất bại');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Không kết nối được "${device.name}".'),
          ),
        );
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => selectedDevice = device);
    _setLog('Đã kết nối: ${device.name} ✓');
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Đã kết nối ${device.name} ✓'),
        ),
      );
  }

  Future<void> printTest() async {
    if (selectedDevice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa chọn máy in')));
      return;
    }
    final isConn = await PrintBluetoothThermal.connectionStatus;
    if (!isConn) {
      await connectPrinter(selectedDevice!);
      if (!await PrintBluetoothThermal.connectionStatus) return;
    }
    setState(() => isPrinting = true);
    _setLog('Đang build bytes...');
    try {
      final bytes = _buildTestBytes();
      _setLog('Gửi ${bytes.length} bytes...');
      final ok = await PrintBluetoothThermal.writeBytes(bytes);
      _setLog(ok ? 'In thành công ✓' : 'In thất bại ✗');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ok ? Colors.green : Colors.red,
            content: Text(ok ? 'In thành công ✓' : 'In thất bại ✗'),
          ),
        );
    } catch (e) {
      _setLog('Lỗi: $e');
    }
    setState(() => isPrinting = false);
  }

  List<int> _buildTestBytes() {
    List<int> b = [];
    b += escInit();
    // TCVN3: dùng ESC t=0 (default codepage), ESC R=0
    // Font TCVN3 built-in của máy in sẽ render 0x80-0xFF thành chữ tiếng Việt
    b += escR(0);
    b += escT(0);

    b += escBold(true);
    b += escCenter();
    b += asciiLine('== TEST TIENG VIET TCVN3 ==');
    b += escBold(false);
    b += hrLine();

    b += escLeft();
    b += vietLine('Cảm ơn quý khách hẹn gặp lại');
    b += vietLine('Địa chỉ: 123 Nguyễn Văn A, Q.1');
    b += vietLine('Điện thoại: 0901 234 567');
    b += hrLine();

    b += escBold(true);
    b += vietLine('Tổng tiền:        150.000d');
    b += vietLine('Da thanh toán:    200.000d');
    b += vietLine('Tiền thừa:         50.000d');
    b += escBold(false);
    b += hrLine();

    b += escCenter();
    b += vietLine('Hẹn gặp lại quý khách!');
    b += vietLine('Chúc quý khách một ngày tốt lành');
    b += hrLine();

    b += [0x0A, 0x0A, 0x0A];
    b += escCut();
    return b;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('In Tiếng Việt Bluetooth'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadDevices,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (selectedDevice != null ? Colors.green : Colors.grey)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    selectedDevice != null
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: selectedDevice != null ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDevice?.name ?? 'Chưa kết nối',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: selectedDevice != null
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                      ),
                      if (selectedDevice != null)
                        Text(
                          selectedDevice!.macAdress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (_log.isNotEmpty)
                        Text(
                          _log,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dùng TCVN3 encoding — mỗi ký tự = 1 byte\n'
                    'Không dùng combining diacritics → in đúng dấu',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : loadDevices,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Tìm máy in'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (isPrinting || selectedDevice == null)
                          ? null
                          : printTest,
                      icon: isPrinting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print, size: 18),
                      label: Text(isPrinting ? 'Đang in...' : 'In test'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (devices.isEmpty && !isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.print_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bấm "Tìm máy in" để bắt đầu',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: devices.length,
                itemBuilder: (_, i) => _deviceTile(devices[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _deviceTile(BluetoothInfo device) {
    final isSelected = selectedDevice?.macAdress == device.macAdress;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: Colors.green.shade300, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isSelected ? Colors.green : Colors.blue).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.print,
            color: isSelected ? Colors.green : Colors.blue,
            size: 22,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          device.macAdress,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => connectPrinter(device),
                child: const Text('Kết nối', style: TextStyle(fontSize: 13)),
              ),
      ),
    );
  }
}
