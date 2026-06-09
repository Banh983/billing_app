import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:billing_app/models/store_config_model.dart';
import 'package:billing_app/provider/auth_provider.dart';
import 'package:billing_app/provider/billing_record_provider.dart';
import 'package:billing_app/services/record_print_service.dart';
import 'package:billing_app/services/store_config_service.dart';
import 'package:billing_app/ui/billing_period_tab/components/printer_settings_card.dart';
import 'package:billing_app/ui/billing_period_tab/print_preview_page.dart';
import 'package:billing_app/ui/dialog/confirm_action_dialog.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';

class BillingRecordPrintController extends ChangeNotifier {
  final RecordPrintService _recordPrintService = RecordPrintService();
  final StoreConfigService _storeConfigService = StoreConfigService();

  BluetoothInfo? selectedPrinter;
  PaperSizeType paperSize = PaperSizeType.mm58;

  bool isPrinting = false;
  bool isOpeningPreview = false;
  bool _isWaitingBluetooth = false;

  Future<void> handleAppResumed(BuildContext context) async {
    if (!_isWaitingBluetooth) return;

    _isWaitingBluetooth = false;

    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (!context.mounted) return;

    if (isEnabled) {
      await selectPrinter(context);
    }
  }

  Future<bool> _requestBluetoothPermissions(BuildContext context) async {
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final bluetoothScan = await Permission.bluetoothScan.request();

    if (bluetoothConnect.isGranted && bluetoothScan.isGranted) {
      return true;
    }

    if (!context.mounted) return false;

    bool openSettings = false;

    await showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: "Cần quyền Bluetooth",
        message:
            "Ứng dụng cần quyền Bluetooth để tìm và kết nối máy in.\n\nVui lòng cấp quyền để tiếp tục.",
        cancelText: "Để sau",
        confirmText: "Mở cài đặt",
        confirmColor: Colors.red,
        icon: Icons.bluetooth_disabled_outlined,
        iconColor: Colors.red,
        onConfirm: () {
          openSettings = true;
        },
      ),
    );

    if (openSettings) {
      await openAppSettings();
    }

    return false;
  }

  Future<bool> _ensureBluetoothEnabled(BuildContext context) async {
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (isEnabled) return true;

    if (!context.mounted) return false;

    bool openBluetoothSettings = false;

    await showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: "Bật Bluetooth",
        message:
            "Bluetooth hiện đang tắt.\n\nVui lòng bật Bluetooth để chọn và kết nối máy in.",
        cancelText: "Hủy",
        confirmText: "Bật Bluetooth",
        confirmColor: Colors.blue,
        icon: Icons.bluetooth,
        iconColor: Colors.blue,
        onConfirm: () {
          openBluetoothSettings = true;
        },
      ),
    );

    if (!openBluetoothSettings) return false;

    _isWaitingBluetooth = true;

    await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);

    return false;
  }

  Future<void> selectPrinter(BuildContext context) async {
    final hasPermission = await _requestBluetoothPermissions(context);

    if (!hasPermission) return;

    final isEnabled = await _ensureBluetoothEnabled(context);

    if (!isEnabled) return;

    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;

    if (!context.mounted) return;

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Không tìm thấy máy in. Hãy ghép đôi máy in trong cài đặt Bluetooth.",
          ),
        ),
      );
      return;
    }

    final BluetoothInfo? chosen = await showModalBottomSheet<BluetoothInfo>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Chọn máy in",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.print),
                title: Text(devices[i].name),
                subtitle: Text(devices[i].macAdress),
                onTap: () => Navigator.pop(context, devices[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (chosen == null) return;

    selectedPrinter = chosen;
    notifyListeners();

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đã chọn: ${chosen.name}")));
  }

  Future<void> selectPaperSize(BuildContext context) async {
    final result = await showModalBottomSheet<PaperSizeType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Chọn khổ giấy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("58mm"),
            trailing: paperSize == PaperSizeType.mm58
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => Navigator.pop(context, PaperSizeType.mm58),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("80mm"),
            trailing: paperSize == PaperSizeType.mm80
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => Navigator.pop(context, PaperSizeType.mm80),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (result == null) return;

    paperSize = result;
    notifyListeners();
  }

  Future<List<int>> _buildImageTicketBytes(Uint8List receiptImageBytes) async {
    final profile = await CapabilityProfile.load();

    final paper = paperSize == PaperSizeType.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;

    final generator = Generator(paper, profile);

    final decodedImage = img.decodeImage(receiptImageBytes);

    if (decodedImage == null) {
      throw Exception("Không thể đọc ảnh phiếu thu để in");
    }

    final int targetWidth = paperSize == PaperSizeType.mm58 ? 384 : 576;

    final resizedImage = img.copyResize(
      decodedImage,
      width: targetWidth,
      interpolation: img.Interpolation.average,
    );

    List<int> bytes = [];

    bytes += generator.reset();
    bytes += generator.imageRaster(resizedImage, align: PosAlign.center);
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  Future<void> _ensureConnected() async {
    if (selectedPrinter == null) {
      throw Exception("Chưa chọn máy in. Vui lòng chọn máy in trước.");
    }

    final bool alreadyConnected = await PrintBluetoothThermal.connectionStatus;

    if (alreadyConnected) return;

    bool connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: selectedPrinter!.macAdress,
    );

    if (!connected) {
      await Future.delayed(const Duration(milliseconds: 500));

      connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: selectedPrinter!.macAdress,
      );
    }

    if (!connected) {
      throw Exception(
        'Không thể kết nối máy in "${selectedPrinter!.name}".\n'
        'Kiểm tra máy in đã bật và còn pin.',
      );
    }

    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _printBill({
    required BuildContext context,
    required BillingRecordProvider provider,
    required int recordId,
    required Uint8List receiptImageBytes,
    required bool shouldUpdateDatabase,
  }) async {
    if (selectedPrinter == null) {
      throw Exception("Chưa chọn máy in. Vui lòng chọn máy in trước.");
    }

    if (isPrinting) return;

    isPrinting = true;
    notifyListeners();

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception("Phiên đăng nhập đã hết hạn");
      }

      await provider.fetchRecordDetail(recordId);

      final record = provider.selectedRecord;

      if (record == null) {
        throw Exception("Không tìm thấy hóa đơn.");
      }

      if (shouldUpdateDatabase && record.collectionStatus == "CHUA_THU") {
        await _recordPrintService.printBill(
          recordId: recordId,
          collectedAmount: record.amountDue,
          token: token,
        );

        await provider.fetchRecordDetail(recordId);
      }

      final List<int> ticketBytes = await _buildImageTicketBytes(
        receiptImageBytes,
      );

      await _ensureConnected();

      final bool result = await PrintBluetoothThermal.writeBytes(ticketBytes);

      if (!result) {
        throw Exception("Gửi lệnh in thất bại. Vui lòng thử lại.");
      }

      await provider.fetchRecordDetail(recordId);
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }

  Future<void> openPreview({
    required BuildContext context,
    required BillingRecordProvider provider,
    required int recordId,
    required bool shouldUpdateDatabase,
  }) async {
    if (isOpeningPreview) return;

    final record = provider.selectedRecord;

    if (record == null) return;

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phiên đăng nhập đã hết hạn"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    isOpeningPreview = true;
    notifyListeners();

    try {
      final StoreConfigModel config = await _storeConfigService.getConfig(
        token: token,
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrintPreviewPage(
            record: record,
            storeConfig: config,
            currentUser: authProvider.user,
            printerName: selectedPrinter?.name ?? "Chưa chọn máy in",
            paperSizeLabel: paperSize == PaperSizeType.mm58 ? "58mm" : "80mm",
            hasSelectedPrinter: selectedPrinter != null,
            showPrintButton: shouldUpdateDatabase,
            onSelectPrinter: () async {
              await selectPrinter(context);
              return selectedPrinter?.name;
            },
            onConfirm: (receiptImageBytes) async {
              await _printBill(
                context: context,
                provider: provider,
                recordId: recordId,
                receiptImageBytes: receiptImageBytes,
                shouldUpdateDatabase: shouldUpdateDatabase,
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      isOpeningPreview = false;
      notifyListeners();
    }
  }
}
