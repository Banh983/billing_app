import 'dart:typed_data';

import 'package:billing_app/models/store_config_model.dart';
import 'package:billing_app/services/store_config_service.dart';
import 'package:billing_app/ui/billing_period_tab/components/printer_settings_card.dart';
import 'package:billing_app/ui/billing_period_tab/components/record_detail_card.dart';
import 'package:billing_app/ui/billing_period_tab/print_preview_page.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/bill_data_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/billing_record_provider.dart';
import '../../services/record_print_service.dart';
import 'components/info_tile.dart';

Future<Uint8List> encodeViet(String s) async {
  try {
    return await CharsetConverter.encode("windows-1258", s);
  } catch (_) {
    return Uint8List.fromList(s.codeUnits);
  }
}

List<int> selectCodePage1258() => [0x1B, 0x74, 0x1E];

Future<List<int>> vietText(
  Generator gen,
  String text, {
  PosStyles styles = const PosStyles(),
  int? linesAfter,
}) async {
  final encoded = await encodeViet(text);

  return gen.textEncoded(encoded, styles: styles, linesAfter: linesAfter ?? 0);
}

class BillingRecordDetailPage extends StatefulWidget {
  final int recordId;

  const BillingRecordDetailPage({super.key, required this.recordId});

  @override
  State<BillingRecordDetailPage> createState() =>
      _BillingRecordDetailPageState();
}

class _BillingRecordDetailPageState extends State<BillingRecordDetailPage> {
  final currencyFormat = NumberFormat("#,###", "vi_VN");
  final dateFormat = DateFormat("dd/MM/yyyy HH:mm", "vi_VN");

  final RecordPrintService _recordPrintService = RecordPrintService();
  final StoreConfigService _storeConfigService = StoreConfigService();

  BluetoothInfo? selectedPrinter;
  PaperSizeType paperSize = PaperSizeType.mm58;

  bool _isPrinting = false;
  bool _isOpeningPreview = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BillingRecordProvider>().fetchRecordDetail(widget.recordId);
    });
  }

  Future<void> _selectPrinter() async {
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final bluetoothScan = await Permission.bluetoothScan.request();

    if (!bluetoothConnect.isGranted || !bluetoothScan.isGranted) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bạn cần cho phép quyền Bluetooth để chọn máy in"),
        ),
      );
      return;
    }

    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (!isEnabled) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bluetooth chưa được bật trên điện thoại"),
        ),
      );
      return;
    }

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

  Future<List<int>> _buildTicketBytes(BillDataModel bill) async {
    final profile = await CapabilityProfile.load();

    final paper = paperSize == PaperSizeType.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;

    final generator = Generator(paper, profile);

    List<int> bytes = [];

    bytes += generator.reset();
    bytes += selectCodePage1258();

    bytes += await vietText(
      generator,
      bill.storeName.isNotEmpty ? bill.storeName : "PHIẾU THU",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if (bill.address.isNotEmpty) {
      bytes += await vietText(
        generator,
        bill.address,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (bill.hotline.isNotEmpty) {
      bytes += await vietText(
        generator,
        "Hotline: ${bill.hotline}",
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.emptyLines(1);

    bytes += await vietText(
      generator,
      "PHIẾU THU CƯỚC VIỄN THÔNG",
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += await vietText(
      generator,
      "${bill.customerCode}-${DateFormat("ddMMyyyy").format(DateTime.now())}",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    bytes += await vietText(generator, "Khách hàng: ${bill.customerName}");
    bytes += await vietText(generator, "Mã KH:      ${bill.customerCode}");

    if (bill.subscriberNumber.isNotEmpty) {
      bytes += await vietText(
        generator,
        "Số TB:      ${bill.subscriberNumber}",
      );
    }

    if (bill.fullAddress.isNotEmpty) {
      bytes += await vietText(generator, "Địa chỉ:   ${bill.fullAddress}");
    }

    bytes += generator.hr();

    bytes += await vietText(generator, "Kỳ hoá đơn: ${bill.billingPeriodName}");

    if (bill.serviceType.isNotEmpty) {
      bytes += await vietText(generator, "Dịch vụ:    ${bill.serviceType}");
    }

    if (bill.collectedAt != null) {
      bytes += await vietText(
        generator,
        "Ngày thu:   ${dateFormat.format(bill.collectedAt!.toLocal())}",
      );
    }

    bytes += generator.emptyLines(1);

    final colHeader1 = await encodeViet("NỘI DUNG");
    final colHeader2 = await encodeViet("TIỀN");

    bytes += generator.row([
      PosColumn(
        textEncoded: colHeader1,
        width: 8,
        styles: const PosStyles(bold: true, underline: true),
      ),
      PosColumn(
        textEncoded: colHeader2,
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          underline: true,
        ),
      ),
    ]);

    final itemName = await encodeViet(
      bill.serviceType.isNotEmpty ? bill.serviceType : "Cước viễn thông",
    );

    bytes += generator.row([
      PosColumn(textEncoded: itemName, width: 8),
      PosColumn(
        text: currencyFormat.format(bill.amountDue),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    final totalLabel = await encodeViet("TỔNG CỘNG");

    bytes += generator.row([
      PosColumn(
        textEncoded: totalLabel,
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currencyFormat.format(bill.amountDue),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();

    bytes += await vietText(
      generator,
      "Số tiền đã thu:",
      styles: const PosStyles(bold: true),
    );

    bytes += await vietText(
      generator,
      "${currencyFormat.format(bill.collectedAmount)} đ",
      styles: const PosStyles(
        align: PosAlign.right,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();

    final nvLabel = await encodeViet("NVBH:");
    final nvName = await encodeViet(bill.collectedBy);

    bytes += generator.row([
      PosColumn(textEncoded: nvLabel, width: 5),
      PosColumn(
        textEncoded: nvName,
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (bill.billPrintedAt != null) {
      final printTimeLabel = await encodeViet("Giờ in:");

      bytes += generator.row([
        PosColumn(textEncoded: printTimeLabel, width: 5),
        PosColumn(
          text: dateFormat.format(bill.billPrintedAt!.toLocal()),
          width: 7,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    if (bill.adsText.isNotEmpty) {
      bytes += await vietText(
        generator,
        bill.adsText,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

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

  Future<void> _printBill(BillingRecordProvider provider) async {
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

      final BillDataModel billData = await _recordPrintService.getBillData(
        recordId: widget.recordId,
        token: token,
      );

      final List<int> ticketBytes = await _buildTicketBytes(billData);

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
            onConfirm: () async {
              await _printBill(provider);

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
                      icon: _isPrinting
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
                        _isPrinting
                            ? "Đang in..."
                            : isUnpaid
                            ? "Thu tiền và in phiếu"
                            : "In lại phiếu thu",
                      ),
                      onPressed: _isPrinting
                          ? null
                          : () async {
                              try {
                                await _printBill(provider);

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isUnpaid
                                          ? "In phiếu thu thành công ✓"
                                          : "In lại phiếu thu thành công ✓",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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
