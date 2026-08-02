import 'package:flutter/services.dart';

class DeviceService {
  static const platform = MethodChannel('com.saathi.device/control');

  // Battery
  static Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getBatteryInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('Failed to get battery info: $e');
    }
  }

  // Storage
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getStorageInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('Failed to get storage info: $e');
    }
  }

  // Apps
  static Future<List<Map<String, dynamic>>> getAppsList() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getAppsList');
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Failed to get apps list: $e');
    }
  }

  static Future<void> launchApp(String packageName) async {
    try {
      await platform.invokeMethod('launchApp', {'package': packageName});
    } catch (e) {
      throw Exception('Failed to launch app: $e');
    }
  }

  static Future<void> closeApp(String packageName) async {
    try {
      await platform.invokeMethod('closeApp', {'package': packageName});
    } catch (e) {
      throw Exception('Failed to close app: $e');
    }
  }

  // WiFi
  static Future<Map<String, dynamic>> getWiFiStatus() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getWiFiStatus');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('Failed to get WiFi status: $e');
    }
  }

  static Future<void> toggleWiFi(bool enable) async {
    try {
      await platform.invokeMethod('toggleWiFi', {'enable': enable});
    } catch (e) {
      throw Exception('Failed to toggle WiFi: $e');
    }
  }

  // Bluetooth
  static Future<Map<String, dynamic>> getBluetoothStatus() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getBluetoothStatus');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('Failed to get Bluetooth status: $e');
    }
  }

  static Future<void> toggleBluetooth(bool enable) async {
    try {
      await platform.invokeMethod('toggleBluetooth', {'enable': enable});
    } catch (e) {
      throw Exception('Failed to toggle Bluetooth: $e');
    }
  }

  // SMS
  static Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      await platform.invokeMethod(
        'sendSMS',
        {'phoneNumber': phoneNumber, 'message': message},
      );
    } catch (e) {
      throw Exception('Failed to send SMS: $e');
    }
  }

  // Contacts
  static Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getContacts');
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  // Settings
  static Future<void> openSettings() async {
    try {
      await platform.invokeMethod('openSettings');
    } catch (e) {
      throw Exception('Failed to open settings: $e');
    }
  }
}