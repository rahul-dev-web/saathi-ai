import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data_service.dart';
import '../models/device_model.dart';

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>(
  (ref) => DeviceNotifier(),
);

class DeviceState {
  final Battery? battery;
  final Storage? storage;
  final WiFi? wifi;
  final Bluetooth? bluetooth;
  final List<App> apps;
  final List<Contact> contacts;
  final bool isLoading;
  final String? error;

  DeviceState({
    this.battery,
    this.storage,
    this.wifi,
    this.bluetooth,
    this.apps = const [],
    this.contacts = const [],
    this.isLoading = false,
    this.error,
  });

  DeviceState copyWith({
    Battery? battery,
    Storage? storage,
    WiFi? wifi,
    Bluetooth? bluetooth,
    List<App>? apps,
    List<Contact>? contacts,
    bool? isLoading,
    String? error,
  }) {
    return DeviceState(
      battery: battery ?? this.battery,
      storage: storage ?? this.storage,
      wifi: wifi ?? this.wifi,
      bluetooth: bluetooth ?? this.bluetooth,
      apps: apps ?? this.apps,
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier() : super(DeviceState());

  Future<void> getBatteryInfo() async {
    state = state.copyWith(isLoading: true);
    try {
      final batteryData = await DeviceService.getBatteryInfo();
      final battery = Battery.fromJson(batteryData);
      state = state.copyWith(battery: battery, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getStorageInfo() async {
    state = state.copyWith(isLoading: true);
    try {
      final storageData = await DeviceService.getStorageInfo();
      final storage = Storage.fromJson(storageData);
      state = state.copyWith(storage: storage, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getAppsList() async {
    state = state.copyWith(isLoading: true);
    try {
      final appsData = await DeviceService.getAppsList();
      final apps = appsData.map((app) => App.fromJson(app)).toList();
      state = state.copyWith(apps: apps, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> launchApp(String packageName) async {
    try {
      await DeviceService.launchApp(packageName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> closeApp(String packageName) async {
    try {
      await DeviceService.closeApp(packageName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getWiFiStatus() async {
    try {
      final wifiData = await DeviceService.getWiFiStatus();
      final wifi = WiFi.fromJson(wifiData);
      state = state.copyWith(wifi: wifi);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleWiFi(bool enable) async {
    try {
      await DeviceService.toggleWiFi(enable);
      await getWiFiStatus();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getBluetoothStatus() async {
    try {
      final btData = await DeviceService.getBluetoothStatus();
      final bluetooth = Bluetooth.fromJson(btData);
      state = state.copyWith(bluetooth: bluetooth);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleBluetooth(bool enable) async {
    try {
      await DeviceService.toggleBluetooth(enable);
      await getBluetoothStatus();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      await DeviceService.sendSMS(phoneNumber, message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final contactsData = await DeviceService.getContacts();
      final contacts = contactsData.map((c) => Contact.fromJson(c)).toList();
      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> openSettings() async {
    try {
      await DeviceService.openSettings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshAllInfo() async {
    await getBatteryInfo();
    await getStorageInfo();
    await getAppsList();
    await getWiFiStatus();
    await getBluetoothStatus();
    await getContacts();
  }
}
