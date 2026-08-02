import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/device_model.dart';
import '../../providers/device_provider.dart';

class DeviceControlScreen extends ConsumerStatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  ConsumerState<DeviceControlScreen> createState() =>
      _DeviceControlScreenState();
}

class _DeviceControlScreenState extends ConsumerState<DeviceControlScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(deviceProvider.notifier).refreshAllInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      appBar: AppBar(
        title: const Text('Device Control'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(deviceProvider.notifier).refreshAllInfo();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(deviceProvider.notifier).refreshAllInfo();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BatteryCard(battery: deviceState.battery),
            const SizedBox(height: 16),
            _StorageCard(storage: deviceState.storage),
            const SizedBox(height: 16),
            _WiFiCard(
              wifi: deviceState.wifi,
              onToggle: (enable) {
                ref.read(deviceProvider.notifier).toggleWiFi(enable);
              },
            ),
            const SizedBox(height: 16),
            _BluetoothCard(
              bluetooth: deviceState.bluetooth,
              onToggle: (enable) {
                ref.read(deviceProvider.notifier).toggleBluetooth(enable);
              },
            ),
            const SizedBox(height: 16),
            _AppsCard(
              apps: deviceState.apps,
              onAppLaunch: (packageName) {
                ref.read(deviceProvider.notifier).launchApp(packageName);
              },
            ),
            const SizedBox(height: 16),
            _ContactsCard(contacts: deviceState.contacts),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(deviceProvider.notifier).openSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
            if (deviceState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: ${deviceState.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BatteryCard extends StatelessWidget {
  final Battery? battery;

  const _BatteryCard({required this.battery});

  @override
  Widget build(BuildContext context) {
    if (battery == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF151A22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Battery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: battery!.percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation(
                  battery!.percentage > 50
                      ? Colors.green
                      : battery!.percentage > 20
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${battery!.percentage}% ${battery!.isCharging ? 'Charging' : ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Temperature: ${battery!.temperature}°C',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  final Storage? storage;

  const _StorageCard({required this.storage});

  @override
  Widget build(BuildContext context) {
    if (storage == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF151A22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: storage!.percentageUsed / 100,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${storage!.usedStorage} GB / ${storage!.totalStorage} GB (${storage!.percentageUsed}%)',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _WiFiCard extends StatelessWidget {
  final WiFi? wifi;
  final Function(bool) onToggle;

  const _WiFiCard({
    required this.wifi,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (wifi == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF151A22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WiFi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: wifi!.isEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Connected: ${wifi!.ssid}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Speed: ${wifi!.linkSpeed} Mbps',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _BluetoothCard extends StatelessWidget {
  final Bluetooth? bluetooth;
  final Function(bool) onToggle;

  const _BluetoothCard({
    required this.bluetooth,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (bluetooth == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF151A22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bluetooth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: bluetooth!.isEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Device: ${bluetooth!.deviceName}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Paired Devices: ${bluetooth!.pairedDevices}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppsCard extends StatelessWidget {
  final List<App> apps;
  final Function(String) onAppLaunch;

  const _AppsCard({
    required this.apps,
    required this.onAppLaunch,
  });

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF151A22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apps (${apps.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: apps.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                    title: Text(
                      app.appName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.launch),
                      onPressed: () => onAppLaunch(app.packageName),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsCard extends StatelessWidget {
  final List<Contact> contacts;

  const _ContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF151A22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contacts (${contacts.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: contacts.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(
                      contact.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      contact.phone,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
