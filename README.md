# Billing App

Ứng dụng Flutter dùng để kết nối với Billing Platform Backend, hỗ trợ quản lý hóa đơn và in phiếu thu qua máy in Bluetooth.

## Yêu cầu

* Flutter SDK
* Android Studio
* Thiết bị Android hoặc Android Emulator
* Billing Platform Backend đang hoạt động

## Cài đặt dự án

Clone source code:

```bash
git clone https://github.com/Banh983/billing_app.git
cd billing_app
```

Cài đặt dependencies:

```bash
flutter pub get
```

## Cấu hình Backend

Mở file:

```text
lib/core/config/app_config.dart
```

Cập nhật địa chỉ Backend:

```dart
class AppConfig {
  static const String baseUrl = 'http://YOUR_IPV4:8080';
}
```

### Lưu ý

* Điện thoại và máy tính chạy Backend phải kết nối cùng mạng **WiFi Ninh Kieu 1**.
* Backend phải được khởi động trước khi sử dụng ứng dụng.
* Không sử dụng `localhost` hoặc `127.0.0.1`.

Ví dụ:

```dart
class AppConfig {
  static const String baseUrl = 'http://192.168.1.164:8080';
}
```

## Chạy ứng dụng

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

File APK sau khi build:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Sử dụng

1. Đăng nhập bằng tài khoản được cấp.
2. Thực hiện các chức năng quản lý hóa đơn.
3. Để in phiếu thu:

   * Bật Bluetooth trên điện thoại.
   * Bật máy in Bluetooth.
   * Chọn máy in trong ứng dụng.
   * Tiến hành in phiếu thu.

## Một số lỗi thường gặp

### Không kết nối được Backend

* Kiểm tra Backend đã chạy chưa.
* Kiểm tra địa chỉ IPv4 trong `AppConfig`.
* Kiểm tra điện thoại và máy tính có cùng mạng WiFi hay không.
* Kiểm tra Firewall của Windows.

### Không tìm thấy máy in Bluetooth

* Bật Bluetooth.
* Pair máy in trước trong cài đặt điện thoại.
* Cấp quyền Bluetooth cho ứng dụng.

## Công nghệ sử dụng

* Flutter
* Dart
* REST API
* Bluetooth ESC/POS
* Spring Boot Backend
