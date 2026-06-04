class StoreConfigModel {
  final String storeName;
  final String address;
  final String hotline;
  final String adsText;
  final String? qrImagePath;

  StoreConfigModel({
    required this.storeName,
    required this.address,
    required this.hotline,
    required this.adsText,
    this.qrImagePath,
  });

  factory StoreConfigModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;

    return StoreConfigModel(
      storeName: data["storeName"]?.toString() ?? "",
      address: data["address"]?.toString() ?? "",
      hotline: data["hotline"]?.toString() ?? "",
      adsText: data["adsText"]?.toString() ?? "",
      qrImagePath: data["qrImagePath"]?.toString(),
    );
  }
}
