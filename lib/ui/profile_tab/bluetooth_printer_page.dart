import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothPrinterPage extends StatefulWidget {
  const BluetoothPrinterPage({super.key});

  @override
  State<BluetoothPrinterPage> createState() => _BluetoothPrinterPageState();
}

class _BluetoothPrinterPageState extends State<BluetoothPrinterPage> {
  List<BluetoothInfo> devices = [];
  BluetoothInfo? selectedDevice;
  bool isLoading = true;
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  // =========================
  // INIT BLUETOOTH
  // =========================
  Future<void> initBluetooth() async {
    // Kiểm tra quyền Bluetooth (Android 12+)
    final bool hasPermission =
        await PrintBluetoothThermal.isPermissionBluetoothGranted;
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Chưa cấp quyền Bluetooth. Vui lòng cấp quyền trong cài đặt.",
          ),
        ),
      );
      return;
    }

    // Kiểm tra Bluetooth có bật không
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng bật Bluetooth trước")),
      );
      setState(() => isLoading = false);
      return;
    }

    await loadDevices();
  }

  // =========================
  // LOAD DEVICES
  // =========================
  Future<void> loadDevices() async {
    setState(() => isLoading = true);

    try {
      // Android: trả về danh sách đã ghép đôi
      // iOS: quét thiết bị gần
      final List<BluetoothInfo> paired =
          await PrintBluetoothThermal.pairedBluetooths;

      setState(() => devices = paired);
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Không thể tải danh sách máy in"),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // =========================
  // CONNECT PRINTER
  // =========================
  Future<void> connectPrinter(BluetoothInfo device) async {
    try {
      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      if (!connected) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Kết nối thất bại: ${device.name}"),
          ),
        );
        return;
      }

      setState(() => selectedDevice = device);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Đã kết nối ${device.name}"),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Kết nối thất bại: $e"),
        ),
      );
    }
  }

  // =========================
  // PRINT TEST
  // =========================
  Future<void> printTest() async {
    if (selectedDevice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Chưa chọn máy in")));
      return;
    }

    // Kiểm tra còn kết nối không
    final bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (!isConnected) {
      // Thử kết nối lại
      final bool reconnected = await PrintBluetoothThermal.connect(
        macPrinterAddress: selectedDevice!.macAdress,
      );
      if (!reconnected) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Mất kết nối máy in. Vui lòng kết nối lại."),
          ),
        );
        return;
      }
    }

    setState(() => isPrinting = true);

    try {
      final List<int> bytes = await _buildTestTicket();
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text(
            result ? "In test thành công ✓" : "In thất bại, thử lại",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Lỗi: $e")),
      );
    }

    setState(() => isPrinting = false);
  }

  // =========================
  // BUILD TEST TICKET BYTES
  // =========================
  Future<List<int>> _buildTestTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final dateStr = DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now());

    List<int> bytes = [];
    bytes += generator.reset();

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
      'IN TEST THÀNH CÔNG',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Ngày:', width: 4),
      PosColumn(
        text: dateStr,
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Máy in:', width: 4),
      PosColumn(
        text: selectedDevice?.name ?? '',
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.text(
      'Cảm ơn quý khách!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  // =========================
  // PRINTER ITEM WIDGET
  // =========================
  Widget buildPrinterItem(BluetoothInfo device) {
    final bool isSelected = selectedDevice?.macAdress == device.macAdress;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.print,
            color: isSelected ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(device.macAdress),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                ),
                onPressed: () => connectPrinter(device),
                child: const Text(
                  "Kết nối",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Máy in Bluetooth"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: loadDevices, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // =========================
          // STATUS CARD
          // =========================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selectedDevice != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    selectedDevice != null
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: selectedDevice != null ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Máy in hiện tại",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDevice?.name ?? "Chưa kết nối",
                        style: TextStyle(
                          color: selectedDevice != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // PRINT TEST BUTTON
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: isPrinting ? null : printTest,
                icon: isPrinting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.receipt_long, color: Colors.white),
                label: Text(
                  isPrinting ? "Đang in..." : "In bill test",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // DEVICE LIST
          // =========================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.print_disabled,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Không tìm thấy máy in",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Hãy ghép đôi máy in trong\nCài đặt > Bluetooth",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: loadDevices,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Thử lại"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: devices.length,
                    itemBuilder: (context, index) =>
                        buildPrinterItem(devices[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
