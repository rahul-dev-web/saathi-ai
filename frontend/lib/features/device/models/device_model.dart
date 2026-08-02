class Battery {
  final int percentage;
  final int health;
  final int temperature;
  final int voltage;
  final bool isCharging;

  Battery({
    required this.percentage,
    required this.health,
    required this.temperature,
    required this.voltage,
    required this.isCharging,
  });

  factory Battery.fromJson(Map<String, dynamic> json) {
    return Battery(
      percentage: json['percentage'] ?? 0,
      health: json['health'] ?? 0,
      temperature: json['temperature'] ?? 0,
      voltage: json['voltage'] ?? 0,
      isCharging: json['isCharging'] ?? false,
    );
  }
}

class Storage {
  final int totalStorage;
  final int usedStorage;
  final int availableStorage;
  final int percentageUsed;

  Storage({
    required this.totalStorage,
    required this.usedStorage,
    required this.availableStorage,
    required this.percentageUsed,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      totalStorage: json['totalStorage'] ?? 0,
      usedStorage: json['usedStorage'] ?? 0,
      availableStorage: json['availableStorage'] ?? 0,
      percentageUsed: json['percentageUsed'] ?? 0,
    );
  }
}

class App {
  final String packageName;
  final String appName;

  App({
    required this.packageName,
    required this.appName,
  });

  factory App.fromJson(Map<String, dynamic> json) {
    return App(
      packageName: json['packageName'] ?? '',
      appName: json['appName'] ?? '',
    );
  }
}

class WiFi {
  final bool isEnabled;
  final String ssid;
  final int linkSpeed;

  WiFi({
    required this.isEnabled,
    required this.ssid,
    required this.linkSpeed,
  });

  factory WiFi.fromJson(Map<String, dynamic> json) {
    return WiFi(
      isEnabled: json['isEnabled'] ?? false,
      ssid: json['ssid'] ?? 'Not Connected',
      linkSpeed: json['linkSpeed'] ?? 0,
    );
  }
}

class Bluetooth {
  final bool isEnabled;
  final String deviceName;
  final int pairedDevices;

  Bluetooth({
    required this.isEnabled,
    required this.deviceName,
    required this.pairedDevices,
  });

  factory Bluetooth.fromJson(Map<String, dynamic> json) {
    return Bluetooth(
      isEnabled: json['isEnabled'] ?? false,
      deviceName: json['deviceName'] ?? 'Unknown',
      pairedDevices: json['pairedDevices'] ?? 0,
    );
  }
}

class Contact {
  final String name;
  final String phone;

  Contact({
    required this.name,
    required this.phone,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}