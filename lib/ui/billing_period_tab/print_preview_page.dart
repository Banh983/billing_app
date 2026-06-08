import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:billing_app/ui/billing_period_tab/components/preview_action_buttons.dart';
import 'package:billing_app/ui/billing_period_tab/components/receipt_preview_card.dart';
import 'package:billing_app/ui/helpers/format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/auth_model.dart';
import '../../models/billing_record_model.dart';
import '../../models/store_config_model.dart';

class PrintPreviewPage extends StatefulWidget {
  final BillingRecordModel record;
  final StoreConfigModel storeConfig;
  final AuthModel? currentUser;
  final String printerName;
  final String paperSizeLabel;
  final bool hasSelectedPrinter;
  final Future<String?> Function() onSelectPrinter;
  final Future<void> Function(Uint8List receiptImageBytes) onConfirm;
  final bool showPrintButton;
  

  const PrintPreviewPage({
    super.key,
    required this.record,
    required this.storeConfig,
    required this.currentUser,
    required this.printerName,
    required this.paperSizeLabel,
    required this.hasSelectedPrinter,
    required this.onSelectPrinter,
    required this.onConfirm,
    this.showPrintButton = true,
  });

  @override
  State<PrintPreviewPage> createState() => _PrintPreviewPageState();
}

class _PrintPreviewPageState extends State<PrintPreviewPage> {
  final GlobalKey _receiptKey = GlobalKey();

  bool _isPrinting = false;
  bool _isSharing = false;
  bool _isSaving = false;
  bool _isSelectingPrinter = false;

  String? _actualPrintTime;
  late String _printerName;
  late bool _hasSelectedPrinter;

  @override
  void initState() {
    super.initState();
    _printerName = widget.printerName;
    _hasSelectedPrinter = widget.hasSelectedPrinter;
  }

  Future<void> _handleSelectPrinter() async {
    if (_isSelectingPrinter) return;

    setState(() => _isSelectingPrinter = true);

    try {
      final selectedName = await widget.onSelectPrinter();

      if (!mounted) return;

      if (selectedName != null && selectedName.trim().isNotEmpty) {
        setState(() {
          _printerName = selectedName;
          _hasSelectedPrinter = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSelectingPrinter = false);
      }
    }
  }

  Future<Uint8List> _captureReceiptImage() async {
    await WidgetsBinding.instance.endOfFrame;

    final receiptContext = _receiptKey.currentContext;

    if (receiptContext == null) {
      throw Exception("Không thể lấy nội dung phiếu thu");
    }

    final boundary = receiptContext.findRenderObject();

    if (boundary == null || boundary is! RenderRepaintBoundary) {
      throw Exception("Không thể render phiếu thu thành ảnh");
    }

    final image = await boundary.toImage(pixelRatio: 3.5);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception("Không thể chuyển phiếu thu thành ảnh");
    }

    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> _captureReceiptImageWithCurrentTime() async {
    setState(() {
      _actualPrintTime = FormatHelper.formatBillPrintDateTime(DateTime.now());
    });

    await WidgetsBinding.instance.endOfFrame;

    final imageBytes = await _captureReceiptImage();

    if (mounted) {
      setState(() => _actualPrintTime = null);
    }

    return imageBytes;
  }

  Future<void> _handlePrint() async {
    if (_isPrinting) return;

    if (!_hasSelectedPrinter) {
      await _handleSelectPrinter();
      if (!_hasSelectedPrinter) return;
    }

    setState(() => _isPrinting = true);

    try {
      final imageBytes = await _captureReceiptImageWithCurrentTime();
      await widget.onConfirm(imageBytes);
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _handleShareImage() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final imageBytes = await _captureReceiptImageWithCurrentTime();

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "phieu_thu_${widget.record.customerCode}_${DateTime.now().millisecondsSinceEpoch}.png";

      final file = File("${tempDir.path}/$fileName");
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Phiếu thu cước viễn thông");
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể chia sẻ ảnh: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _handleSaveImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      if (Platform.isAndroid) {
        await Permission.photos.request();
        await Permission.storage.request();
      }

      final imageBytes = await _captureReceiptImageWithCurrentTime();

      await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name:
            "phieu_thu_${widget.record.customerCode}_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lưu ảnh phiếu thu vào thư viện"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể lưu ảnh: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paperWidth = widget.paperSizeLabel == "80mm" ? 430.0 : 384.0;

    final displayDateTime =
        _actualPrintTime ?? FormatHelper.formatBillPrintDate(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Xem trước phiếu thu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: [
              _PrinterInfo(
                width: paperWidth,
                printerName: _printerName,
                paperSizeLabel: widget.paperSizeLabel,
                hasSelectedPrinter: _hasSelectedPrinter,
                isSelectingPrinter: _isSelectingPrinter,
                onSelectPrinter: _handleSelectPrinter,
              ),
              const SizedBox(height: 12),
              RepaintBoundary(
                key: _receiptKey,
                child: ReceiptPreviewCard(
                  width: paperWidth,
                  record: widget.record,
                  storeConfig: widget.storeConfig,
                  currentUser: widget.currentUser,
                  displayDateTime: displayDateTime,
                ),
              ),
              const SizedBox(height: 16),
              PreviewActionButtons(
                width: paperWidth,
                isPrinting: _isPrinting,
                isSharing: _isSharing,
                isSaving: _isSaving,
                showPrintButton: widget.showPrintButton,
                onPrint: _handlePrint,
                onShare: _handleShareImage,
                onSave: _handleSaveImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrinterInfo extends StatelessWidget {
  final double width;
  final String printerName;
  final String paperSizeLabel;
  final bool hasSelectedPrinter;
  final bool isSelectingPrinter;
  final VoidCallback onSelectPrinter;

  const _PrinterInfo({
    required this.width,
    required this.printerName,
    required this.paperSizeLabel,
    required this.hasSelectedPrinter,
    required this.isSelectingPrinter,
    required this.onSelectPrinter,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = hasSelectedPrinter
        ? Colors.green.shade50
        : Colors.orange.shade50;

    final Color borderColor = hasSelectedPrinter
        ? Colors.green.shade200
        : Colors.orange.shade200;

    final Color iconColor = hasSelectedPrinter
        ? Colors.green
        : Colors.orange.shade800;

    return InkWell(
      onTap: isSelectingPrinter ? null : onSelectPrinter,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            if (isSelectingPrinter)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            else
              Icon(
                hasSelectedPrinter
                    ? Icons.print_rounded
                    : Icons.bluetooth_searching_rounded,
                size: 20,
                color: iconColor,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasSelectedPrinter
                    ? "Máy in: $printerName"
                    : "Chưa chọn máy in - bấm để chọn",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              paperSizeLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
