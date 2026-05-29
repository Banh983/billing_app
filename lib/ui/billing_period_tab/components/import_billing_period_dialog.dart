import 'dart:io';

import 'package:billing_app/provider/billing_period_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImportBillingPeriodDialog extends StatefulWidget {
  const ImportBillingPeriodDialog({super.key});

  @override
  State<ImportBillingPeriodDialog> createState() =>
      _ImportBillingPeriodDialogState();
}

class _ImportBillingPeriodDialogState extends State<ImportBillingPeriodDialog> {
  File? selectedFile;

  bool isLoading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["xlsx"],
    );

    if (result != null) {
      selectedFile = File(result.files.single.path!);

      setState(() {});
    }
  }

  Future<void> upload() async {
    if (selectedFile == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      final provider = context.read<BillingPeriodProvider>();

      final message = await provider.importExcel(selectedFile!);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Excel"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: pickFile, child: const Text("Chọn file")),

          const SizedBox(height: 12),

          Text(selectedFile?.path ?? "Chưa chọn file"),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Huỷ"),
        ),

        ElevatedButton(
          onPressed: isLoading ? null : upload,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Upload"),
        ),
      ],
    );
  }
}
