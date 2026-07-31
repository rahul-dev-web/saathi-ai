import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool autoSyncEnabled = true;
  String selectedTheme = 'dark';
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Setting
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(selectedTheme),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        title: const Text('Light'),
                        value: 'light',
                        groupValue: selectedTheme,
                        onChanged: (value) {
                          setState(() => selectedTheme = value!);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile(
                        title: const Text('Dark'),
                        value: 'dark',
                        groupValue: selectedTheme,
                        onChanged: (value) {
                          setState(() => selectedTheme = value!);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          // Language Setting
          ListTile(
            title: const Text('Language'),
            subtitle: Text(selectedLanguage),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        title: const Text('English'),
                        value: 'en',
                        groupValue: selectedLanguage,
                        onChanged: (value) {
                          setState(() => selectedLanguage = value!);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile(
                        title: const Text('Hindi'),
                        value: 'hi',
                        groupValue: selectedLanguage,
                        onChanged: (value) {
                          setState(() => selectedLanguage = value!);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          // Notifications
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          const Divider(),
          // Auto Sync
          SwitchListTile(
            title: const Text('Auto Sync'),
            value: autoSyncEnabled,
            onChanged: (value) {
              setState(() => autoSyncEnabled = value);
            },
          ),
        ],
      ),
    );
  }
}