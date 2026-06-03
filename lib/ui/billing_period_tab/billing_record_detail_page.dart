// ============================================================
// pubspec.yaml:
//   print_bluetooth_thermal: ^1.2.1
//   esc_pos_utils_plus: ^2.0.4
// ============================================================

import 'package:billing_app/ui/billing_period_tab/print_preview_page.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../provider/billing_record_provider.dart';

// ============================================================
// HELPER: Bỏ dấu tiếng Việt → ASCII
// (máy in nhiệt không hỗ trợ UTF-8)
// Bước 1: map từng ký tự có dấu → không dấu
// Bước 2: fallback — xóa mọi ký tự còn lại ngoài ASCII printable
// ============================================================
String removeDiacritics(String s) {
  const Map<String, String> _map = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'À': 'A',
    'Á': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Ä': 'A',
    'Å': 'A',
    'ă': 'a',
    'ắ': 'a',
    'ặ': 'a',
    'ằ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'Ă': 'A',
    'Ắ': 'A',
    'Ặ': 'A',
    'Ằ': 'A',
    'Ẳ': 'A',
    'Ẵ': 'A',
    'ấ': 'a',
    'ậ': 'a',
    'ầ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'Ấ': 'A',
    'Ậ': 'A',
    'Ầ': 'A',
    'Ẩ': 'A',
    'Ẫ': 'A',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'È': 'E',
    'É': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'ề': 'e',
    'ế': 'e',
    'ệ': 'e',
    'ể': 'e',
    'ễ': 'e',
    'Ề': 'E',
    'Ế': 'E',
    'Ệ': 'E',
    'Ể': 'E',
    'Ễ': 'E',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'Ì': 'I',
    'Í': 'I',
    'Î': 'I',
    'Ï': 'I',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'Ò': 'O',
    'Ó': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'Ö': 'O',
    'ồ': 'o',
    'ố': 'o',
    'ộ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'Ồ': 'O',
    'Ố': 'O',
    'Ộ': 'O',
    'Ổ': 'O',
    'Ỗ': 'O',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ợ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'Ơ': 'O',
    'Ờ': 'O',
    'Ớ': 'O',
    'Ợ': 'O',
    'Ở': 'O',
    'Ỡ': 'O',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'Ù': 'U',
    'Ú': 'U',
    'Û': 'U',
    'Ü': 'U',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ự': 'u',
    'ử': 'u',
    'ữ': 'u',
    'Ư': 'U',
    'Ừ': 'U',
    'Ứ': 'U',
    'Ự': 'U',
    'Ử': 'U',
    'Ữ': 'U',
    'ỳ': 'y',
    'ý': 'y',
    'ỵ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'Ỳ': 'Y',
    'Ý': 'Y',
    'Ỵ': 'Y',
    'Ỷ': 'Y',
    'Ỹ': 'Y',
    'đ': 'd',
    'Đ': 'D',
    'ñ': 'n',
    'Ñ': 'N',
    'ç': 'c',
    'Ç': 'C',
  };
  // Bước 1: thay thế theo map
  final mapped = s.split('').map((c) => _map[c] ?? c).join();
  // Bước 2: xóa mọi ký tự không nằm trong ASCII printable (32–126)
  // để đảm bảo không có ký tự lạ nào lọt qua
  return mapped.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
}

// Shorthand
String p(String s) => removeDiacritics(s);

class BillingRecordDetailPage extends StatefulWidget {
  final int recordId;

  const BillingRecordDetailPage({super.key, required this.recordId});

  @override
  State<BillingRecordDetailPage> createState() =>
      _BillingRecordDetailPageState();
}

enum PaperSizeType { mm58, mm80 }

class _BillingRecordDetailPageState extends State<BillingRecordDetailPage> {
  final currencyFormat = NumberFormat("#,###", "vi_VN");

  BluetoothInfo? selectedPrinter;
  PaperSizeType paperSize = PaperSizeType.mm58;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BillingRecordProvider>().fetchRecordDetail(widget.recordId);
    });
  }

  // ================= CHỌN MÁY IN =================
  Future<void> _selectPrinter() async {
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng bật Bluetooth trước")),
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

  // ================= CHỌN KHỔ GIẤY =================
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
    if (result != null) setState(() => paperSize = result);
  }

  // ================= BUILD TICKET BYTES =================
  Future<List<int>> _buildTicketBytes(dynamic updated) async {
    final profile = await CapabilityProfile.load();
    final paper = paperSize == PaperSizeType.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paper, profile);

    List<int> bytes = [];
    bytes += generator.reset();

    // HEADER — tất cả phải bỏ dấu
    bytes += generator.text(
      p('VIETTEL PHÙNG HIỆP'),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      p('PHIẾU THU CƯỚC VIỄN THÔNG'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      '${p(updated.customerCode)}-'
      '${DateFormat("ddMMyyyy").format(DateTime.now())}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    // THÔNG TIN KHÁCH HÀNG
    bytes += generator.text(p('Khách hàng: ${updated.customerName}'));
    bytes += generator.text(p('Mã KH:      ${updated.customerCode}'));
    bytes += generator.text(p('SĐT:        ${updated.phoneNumber}'));
    bytes += generator.text(p('Địa chỉ:   ${updated.fullAddress ?? ""}'));

    bytes += generator.hr();

    // CHI TIẾT HÓA ĐƠN
    bytes += generator.text(p('Kỳ hoá đơn: ${updated.billingPeriodName}'));
    bytes += generator.emptyLines(1);

    bytes += generator.row([
      PosColumn(
        text: p('NỘI DUNG'),
        width: 8,
        styles: const PosStyles(bold: true, underline: true),
      ),
      PosColumn(
        text: p('TIỀN'),
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          underline: true,
        ),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: p('Cước viễn thông'), width: 8),
      PosColumn(
        text: currencyFormat.format(updated.amountDue),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: p('TỔNG CỘNG'),
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currencyFormat.format(updated.amountDue),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.text(
      p('Số tiền thanh toán:'),
      styles: const PosStyles(bold: true),
    );
    bytes += generator.text(
      '${currencyFormat.format(updated.amountDue)} d',
      styles: const PosStyles(
        align: PosAlign.right,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();

    // NHÂN VIÊN
    bytes += generator.row([
      PosColumn(text: 'NVBH:', width: 5),
      PosColumn(
        text: p('Bùi Diệu Hương'),
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: p('SĐT NV:'), width: 5),
      PosColumn(
        text: '0912345619',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    // FOOTER
    bytes += generator.text(
      p('Cảm ơn quý khách và hẹn gặp lại!'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  // ================= KẾT NỐI MÁY IN =================
  Future<void> _ensureConnected() async {
    // Nếu đang kết nối rồi thì không connect lại
    final bool alreadyConnected = await PrintBluetoothThermal.connectionStatus;
    if (alreadyConnected) return;

    // Thử kết nối lần 1
    bool connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: selectedPrinter!.macAdress,
    );

    if (!connected) {
      // Chờ 500ms rồi thử lần 2
      await Future.delayed(const Duration(milliseconds: 500));
      connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: selectedPrinter!.macAdress,
      );
    }

    if (!connected) {
      throw Exception(
        'Không the ket noi may in "${selectedPrinter!.name}".\n'
        'Kiem tra may in da bat va con pin.',
      );
    }

    // Chờ máy in sẵn sàng sau khi kết nối
    await Future.delayed(const Duration(milliseconds: 400));
  }

  // ================= IN HÓA ĐƠN =================
  Future<void> _printBill(BillingRecordProvider provider) async {
    if (selectedPrinter == null) {
      throw Exception("Chua chon may in. Vui long chon may in truoc.");
    }
    if (_isPrinting) return;
    setState(() => _isPrinting = true);

    try {
      await provider.fetchRecordDetail(widget.recordId);
      final record = provider.selectedRecord;
      if (record == null) throw Exception("Khong tim thay hoa don.");

      if (record.status == "CHUA_THU") {
        await provider.printBill(recordId: widget.recordId);
        await provider.fetchRecordDetail(widget.recordId);
      }

      final updated = provider.selectedRecord;
      if (updated == null) throw Exception("Khong tai duoc du lieu hoa don.");

      // Build bytes trước, kết nối sau — tránh timeout
      final List<int> ticketBytes = await _buildTicketBytes(updated);

      await _ensureConnected();

      final bool result = await PrintBluetoothThermal.writeBytes(ticketBytes);
      if (!result) throw Exception("Gui lenh in that bai. Vui long thu lai.");
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  // ================= XEM TRƯỚC =================
  void _openPreview(BillingRecordProvider provider) {
    final record = provider.selectedRecord;
    if (record == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrintPreviewPage(
          record: record,
          printerName: selectedPrinter?.name ?? "Chưa chọn máy in",
          paperSizeLabel: paperSize == PaperSizeType.mm58 ? "58mm" : "80mm",
          onConfirm: () async {
            await _printBill(provider);
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // ================= WIDGET HELPERS =================
  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ================= BUILD =================
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

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                _card(
                  title: "THÔNG TIN KHÁCH HÀNG",
                  children: [
                    _infoTile("Tên khách hàng", record.customerName),
                    _infoTile("Mã khách hàng", record.customerCode),
                    _infoTile("Số điện thoại", record.phoneNumber),
                    if (record.fullAddress != null)
                      _infoTile("Địa chỉ", record.fullAddress!),
                  ],
                ),

                _card(
                  title: "THÔNG TIN HÓA ĐƠN",
                  children: [
                    _infoTile("Kỳ hoá đơn", record.billingPeriodName),
                    _infoTile(
                      "Số tiền",
                      "${currencyFormat.format(record.amountDue)} đ",
                    ),
                    _infoTile(
                      "Trạng thái",
                      record.status == "CHUA_THU" ? "Chưa thu" : "Đã thu",
                    ),
                  ],
                ),

                _card(
                  title: "CÀI ĐẶT MÁY IN",
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectPrinter,
                            icon: const Icon(Icons.print, size: 18),
                            label: Text(
                              selectedPrinter?.name ?? "Chọn máy in",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _selectPaperSize,
                          icon: const Icon(Icons.straighten, size: 18),
                          label: Text(
                            paperSize == PaperSizeType.mm58 ? "58mm" : "80mm",
                          ),
                        ),
                      ],
                    ),
                    if (selectedPrinter != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${selectedPrinter!.name}  •  ${selectedPrinter!.macAdress}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                if (record.status == "CHUA_THU")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text("Xem trước bản in"),
                            onPressed: () => _openPreview(provider),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
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
                              _isPrinting ? "Đang in..." : "In hóa đơn",
                            ),
                            onPressed: _isPrinting
                                ? null
                                : () async {
                                    try {
                                      await _printBill(provider);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "In hóa đơn thành công ✓",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),

                if (record.status != "CHUA_THU")
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
                          Text(
                            "Hóa đơn này đã được thu tiền",
                            style: TextStyle(color: Colors.green),
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
