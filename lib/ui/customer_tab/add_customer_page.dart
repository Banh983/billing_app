import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/customer_provider.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  final billingPeriodIdController = TextEditingController();

  final customerCodeController = TextEditingController();

  final customerNameController = TextEditingController();

  final subscriberController = TextEditingController();

  final phoneController = TextEditingController();

  final amountController = TextEditingController();

  final provinceController = TextEditingController();

  final wardController = TextEditingController();

  final hamletController = TextEditingController();

  final streetController = TextEditingController();

  final addressController = TextEditingController();

  final serviceTypeController = TextEditingController();

  final consultantController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    billingPeriodIdController.dispose();
    customerCodeController.dispose();
    customerNameController.dispose();
    subscriberController.dispose();
    phoneController.dispose();
    amountController.dispose();
    provinceController.dispose();
    wardController.dispose();
    hamletController.dispose();
    streetController.dispose();
    addressController.dispose();
    serviceTypeController.dispose();
    consultantController.dispose();

    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final success = await context.read<CustomerProvider>().createCustomer(
        billingPeriodId: int.parse(billingPeriodIdController.text.trim()),
        customerCode: customerCodeController.text.trim(),
        customerName: customerNameController.text.trim(),
        subscriberNumber: subscriberController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        amountDue: double.parse(amountController.text.trim()),
        province: provinceController.text.trim(),
        ward: wardController.text.trim(),
        hamlet: hamletController.text.trim(),
        street: streetController.text.trim(),
        fullAddress: addressController.text.trim(),
        serviceType: serviceTypeController.text.trim(),
        assignedConsultantUsername: consultantController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm khách hàng thành công")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<CustomerProvider>().error ??
                  "Không thể thêm khách hàng",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (!requiredField) {
            return null;
          }

          if (value == null || value.trim().isEmpty) {
            return "Không được để trống";
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm khách hàng")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildField(
                label: "Billing Period ID",
                controller: billingPeriodIdController,
                keyboardType: TextInputType.number,
                requiredField: true,
              ),

              buildField(
                label: "Mã khách hàng",
                controller: customerCodeController,
                requiredField: true,
              ),

              buildField(
                label: "Tên khách hàng",
                controller: customerNameController,
                requiredField: true,
              ),

              buildField(
                label: "Mã thuê bao",
                controller: subscriberController,
              ),

              buildField(
                label: "Số điện thoại",
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),

              buildField(
                label: "Số tiền phải thu",
                controller: amountController,
                keyboardType: TextInputType.number,
                requiredField: true,
              ),

              buildField(
                label: "Tỉnh / Thành phố",
                controller: provinceController,
              ),

              buildField(label: "Phường / Xã", controller: wardController),

              buildField(label: "Ấp / Thôn", controller: hamletController),

              buildField(label: "Đường", controller: streetController),

              buildField(
                label: "Địa chỉ đầy đủ",
                controller: addressController,
              ),

              buildField(
                label: "Loại dịch vụ",
                controller: serviceTypeController,
              ),

              buildField(
                label: "Username nhân viên phụ trách",
                controller: consultantController,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("THÊM KHÁCH HÀNG"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
