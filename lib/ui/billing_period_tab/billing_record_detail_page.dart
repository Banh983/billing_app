import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:billing_app/models/store_config_model.dart';
import 'package:billing_app/services/store_config_service.dart';
import 'package:billing_app/ui/billing_period_tab/components/printer_settings_card.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_detail_card.dart';
import 'package:billing_app/ui/billing_period_tab/print_preview_page.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../provider/auth_provider.dart';
import '../../provider/billing_record_provider.dart';
import '../../services/record_print_service.dart';
import 'components/info_tile.dart';

class BillingRecordDetailPage extends StatefulWidget {
  final int recordId;

  const BillingRecordDetailPage({super.key, required this.recordId});

  @override
  State<BillingRecordDetailPage> createState() =>
      _BillingRecordDetailPageState();
}

class _BillingRecordDetailPageState extends State<BillingRecordDetailPage>
    with WidgetsBindingObserver {
  final currencyFormat = NumberFormat("#,###", "vi_VN");

  final RecordPrintService _recordPrintService = RecordPrintService();
  final StoreConfigService _storeConfigService = StoreConfigService();

  BluetoothInfo? selectedPrinter;
  PaperSizeType paperSize = PaperSizeType.mm58;

  bool _isPrinting = false;
  bool _isOpeningPreview = false;
  bool _isWaitingBluetooth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      context.read<BillingRecordProvider>().fetchRecordDetail(widget.recordId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    if (!_isWaitingBluetooth) return;

    _isWaitingBluetooth = false;

    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (!mounted) return;

    if (isEnabled) {
      await _selectPrinter();
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final bluetoothScan = await Permission.bluetoothScan.request();

    if (bluetoothConnect.isGranted && bluetoothScan.isGranted) {
      return true;
    }

    if (!mounted) return false;

    final bool openSettings =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cần quyền Bluetooth"),
            content: const Text(
              "Ứng dụng cần quyền Bluetooth để tìm và kết nối máy in. "
              "Vui lòng cấp quyền để tiếp tục.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Để sau"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Mở cài đặt"),
              ),
            ],
          ),
        ) ??
        false;

    if (openSettings) {
      await openAppSettings();
    }

    return false;
  }

  Future<bool> _ensureBluetoothEnabled() async {
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (isEnabled) return true;

    if (!mounted) return false;

    final bool openBluetoothSettings =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Bật Bluetooth"),
            content: const Text(
              "Bluetooth đang tắt. Vui lòng bật Bluetooth để chọn và kết nối máy in.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.bluetooth),
                label: const Text("Bật Bluetooth"),
              ),
            ],
          ),
        ) ??
        false;

    if (!openBluetoothSettings) return false;

    _isWaitingBluetooth = true;
    await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);

    return false;
  }

  Future<void> _selectPrinter() async {
    final hasPermission = await _requestBluetoothPermissions();

    if (!hasPermission) return;

    final isEnabled = await _ensureBluetoothEnabled();

    if (!isEnabled) return;

    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;

    if (!mounted) return;

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

    setState(() => selectedPrinter = chosen);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đã chọn: ${chosen.name}")));
  }

  Future<void> _selectPaperSize() async {
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

    if (result != null) {
      setState(() => paperSize = result);
    }
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

  Future<void> _printBill(
    BillingRecordProvider provider, {
    required Uint8List receiptImageBytes,
  }) async {
    if (selectedPrinter == null) {
      throw Exception("Chưa chọn máy in. Vui lòng chọn máy in trước.");
    }

    if (_isPrinting) return;

    setState(() => _isPrinting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception("Phiên đăng nhập đã hết hạn");
      }

      await provider.fetchRecordDetail(widget.recordId);

      final record = provider.selectedRecord;

      if (record == null) {
        throw Exception("Không tìm thấy hóa đơn.");
      }

      if (record.collectionStatus == "CHUA_THU") {
        await _recordPrintService.printBill(
          recordId: widget.recordId,
          collectedAmount: record.amountDue,
          token: token,
        );

        await provider.fetchRecordDetail(widget.recordId);
      }

      final List<int> ticketBytes = await _buildImageTicketBytes(
        receiptImageBytes,
      );

      await _ensureConnected();

      final bool result = await PrintBluetoothThermal.writeBytes(ticketBytes);

      if (!result) {
        throw Exception("Gửi lệnh in thất bại. Vui lòng thử lại.");
      }

      await provider.fetchRecordDetail(widget.recordId);
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _openPreview(BillingRecordProvider provider) async {
    if (_isOpeningPreview) return;

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

    setState(() => _isOpeningPreview = true);

    try {
      final StoreConfigModel config = await _storeConfigService.getConfig(
        token: token,
      );

      if (!mounted) return;

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
            onSelectPrinter: () async {
              await _selectPrinter();
              return selectedPrinter?.name;
            },
            onConfirm: (receiptImageBytes) async {
              await _printBill(provider, receiptImageBytes: receiptImageBytes);

              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningPreview = false);
      }
    }
  }

  String _collectionStatusText(String status) {
    if (status == "CHUA_THU") return "Chưa thu";
    if (status == "DA_THANH_TOAN") return "Đã thanh toán";
    return status;
  }

  String _debtStatusText(String status) {
    if (status == "CHUA_GACH_NO") return "Chưa gạch nợ";
    if (status == "DA_GACH_NO") return "Đã gạch nợ";
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        title: const Text("Chi tiết hóa đơn"),
      ),
      body: Consumer<BillingRecordProvider>(
        builder: (context, provider, child) {
          final record = provider.selectedRecord;

          if (record == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isUnpaid = record.collectionStatus == "CHUA_THU";

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                RecordDetailCard(
                  title: "THÔNG TIN KHÁCH HÀNG",
                  titleColor: AppColors.softRed,
                  children: [
                    InfoTile("Tên khách hàng", record.customerName),
                    InfoTile("Mã khách hàng", record.customerCode),
                    InfoTile("Số điện thoại", record.phoneNumber),
                    if (record.fullAddress != null &&
                        record.fullAddress!.isNotEmpty)
                      InfoTile("Địa chỉ", record.fullAddress!),
                  ],
                ),
                RecordDetailCard(
                  title: "THÔNG TIN HÓA ĐƠN",
                  titleColor: AppColors.softRed,
                  children: [
                    InfoTile("Kỳ hoá đơn", record.billingPeriodName),
                    InfoTile(
                      "Số tiền",
                      "${currencyFormat.format(record.amountDue)} đ",
                    ),
                    InfoTile(
                      "Trạng thái thu",
                      _collectionStatusText(record.collectionStatus),
                    ),
                    InfoTile(
                      "Trạng thái gạch nợ",
                      _debtStatusText(record.debtStatus),
                    ),
                  ],
                ),
                RecordDetailCard(
                  title: "CÀI ĐẶT MÁY IN",
                  titleColor: AppColors.softRed,
                  children: [
                    PrinterSettingsCard(
                      selectedPrinter: selectedPrinter,
                      paperSize: paperSize,
                      onSelectPrinter: _selectPrinter,
                      onSelectPaperSize: _selectPaperSize,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: _isOpeningPreview
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.visibility_outlined),
                      label: Text(
                        _isOpeningPreview
                            ? "Đang mở bản xem trước..."
                            : "Xem trước bản in",
                      ),
                      onPressed: _isOpeningPreview
                          ? null
                          : () async => await _openPreview(provider),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isPrinting || _isOpeningPreview
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print),
                      label: Text(
                        _isPrinting || _isOpeningPreview
                            ? "Đang xử lý..."
                            : isUnpaid
                            ? "Xem trước và thu tiền"
                            : "Xem trước và in lại",
                      ),
                      onPressed: _isPrinting || _isOpeningPreview
                          ? null
                          : () async {
                              await _openPreview(provider);
                            },
                    ),
                  ),
                ),

                if (!isUnpaid)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Hóa đơn này đã được thu tiền",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
