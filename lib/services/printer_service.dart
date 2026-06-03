import 'package:billing_app/models/billing_record_model.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

enum PaperSizeType { mm58, mm80 }

class PrinterService {
  static final NumberFormat currencyFormat = NumberFormat("#,###", "vi_VN");

  // =========================
  // PRINT BILLING RECORD
  // =========================
  static Future<void> printBillingRecord({
    required BillingRecordModel record,
    required double collectedAmount,
    required String printerMac,
    PaperSizeType paperSize = PaperSizeType.mm58,
  }) async {
    // Kiểm tra / kết nối máy in
    final bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (!isConnected) {
      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: printerMac,
      );
      if (!connected) {
        throw Exception("Không thể kết nối máy in. Vui lòng thử lại.");
      }
    }

    final List<int> bytes = await _buildTicket(
      record: record,
      collectedAmount: collectedAmount,
      paperSize: paperSize,
    );

    final bool result = await PrintBluetoothThermal.writeBytes(bytes);
    if (!result) {
      throw Exception("Gửi lệnh in thất bại. Vui lòng thử lại.");
    }
  }

  // =========================
  // BUILD TICKET BYTES
  // =========================
  static Future<List<int>> _buildTicket({
    required BillingRecordModel record,
    required double collectedAmount,
    required PaperSizeType paperSize,
  }) async {
    final profile = await CapabilityProfile.load();
    final paper = paperSize == PaperSizeType.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paper, profile);

    List<int> bytes = [];
    bytes += generator.reset();

    // =========================
    // HEADER
    // =========================
    bytes += generator.text(
      'VIETTEL CẦN THƠ',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'PHIẾU THU CƯỚC',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.hr();

    // =========================
    // THÔNG TIN KHÁCH HÀNG
    // =========================
    bytes += generator.row([
      PosColumn(text: 'Mã KH:', width: 5),
      PosColumn(
        text: record.customerCode,
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Khách hàng:', width: 5),
      PosColumn(
        text: record.customerName,
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Số TB:', width: 5),
      PosColumn(
        text: record.subscriberNumber,
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Kỳ cước:', width: 5),
      PosColumn(
        text: record.billingPeriodName,
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    // =========================
    // TIỀN
    // =========================
    bytes += generator.row([
      PosColumn(text: 'Phải thu:', width: 5),
      PosColumn(
        text: '${currencyFormat.format(record.amountDue)} đ',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Thực thu:',
        width: 5,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: '${currencyFormat.format(collectedAmount)} đ',
        width: 7,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.hr();

    // =========================
    // FOOTER
    // =========================
    bytes += generator.text(
      'Cảm ơn quý khách!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}
