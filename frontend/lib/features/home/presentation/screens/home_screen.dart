import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../providers/home_provider.dart';

Future<void> requestDevicePermissions() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  await [
    Permission.contacts,
    Permission.phone,
    Permission.sms,
    Permission.storage,
  ].request();
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestDevicePermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      appBar: AppBar(
        title: const Text('SAATHI AI'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                ref.read(authStateProvider.notifier).logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: homeState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(homeProvider.notifier).loadConversations();
                  await requestDevicePermissions();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _HeroHeader(
                      onTapProfile: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      onTapSettings: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _LaunchCard(
                            title: 'Text Chat',
                            subtitle: 'Type and continue normal conversations',
                            icon: Icons.chat_bubble_outline,
                            accent: const Color(0xFF4F8CFF),
                            onTap: () async {
                              final conversation = await ref
                                  .read(homeProvider.notifier)
                                  .createConversation('Text Chat');
                              if (!context.mounted || conversation == null) {
                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                '/chat',
                                arguments: conversation['id'],
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LaunchCard(
                            title: 'Voice Chat',
                            subtitle: 'Record voice and talk directly',
                            icon: Icons.mic_none_rounded,
                            accent: const Color(0xFF27C5A1),
                            onTap: () async {
                              final conversation = await ref
                                  .read(homeProvider.notifier)
                                  .createConversation('Voice Chat');
                              if (!context.mounted || conversation == null) {
                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                '/voice-chat',
                                arguments: conversation['id'],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DeviceControlCard(
                      onTap: () {
                        Navigator.pushNamed(context, '/device-control');
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Conversations',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                        ),
                        Text(
                          '${homeState.conversations.length}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white54,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (homeState.conversations.isEmpty)
                      _EmptyState(
                        onStartChat: () async {
                          final conversation = await ref
                              .read(homeProvider.notifier)
                              .createConversation('Text Chat');
                          if (!context.mounted || conversation == null) {
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: conversation['id'],
                          );
                        },
                      )
                    else
                      ...homeState.conversations.map(
                        (conversation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ConversationTile(
                            conversation: conversation,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/chat',
                                arguments: conversation['id'],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final VoidCallback onTapProfile;
  final VoidCallback onTapSettings;

  const _HeroHeader({
    required this.onTapProfile,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2440), Color(0xFF0F1629)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF27314F),
                child: Icon(Icons.psychology, color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                onPressed: onTapSettings,
                icon: const Icon(Icons.settings_outlined),
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Welcome back, Rahul',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a mode and continue instantly.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTapProfile,
              icon: const Icon(Icons.person_outline, size: 18),
              label: const Text('Open Profile'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                backgroundColor: Colors.white10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _LaunchCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.28), const Color(0xFF151A22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceControlCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DeviceControlCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFF151A22),
          border: Border.all(color: const Color(0xFF3B455D)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B455D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.smartphone, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Control',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Battery, storage, WiFi, Bluetooth, contacts, SMS and app actions.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151A22),
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF27314F),
          child: Icon(Icons.forum_outlined, color: Colors.white),
        ),
        title: Text(
          conversation['title'] ?? 'Conversation',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          conversation['created_at'] ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onStartChat;

  const _EmptyState({
    required this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151A22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.white54, size: 34),
          const SizedBox(height: 12),
          const Text(
            'No conversations yet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start with text or voice chat from the cards above.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () async => onStartChat(),
            child: const Text('Start Text Chat'),
          ),
        ],
      ),
    );
  }
}
