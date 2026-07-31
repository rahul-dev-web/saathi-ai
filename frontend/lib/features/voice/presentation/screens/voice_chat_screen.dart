import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/voice_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class VoiceChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const VoiceChatScreen({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen> {
  late AudioRecorder audioRecorder;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String? recordingPath;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    audioRecorder = AudioRecorder();
    audioPlayer = AudioPlayer();
    scrollController = ScrollController();
    
    Future.microtask(() {
      ref.read(voiceProvider.notifier).loadMessages(widget.conversationId);
    });
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    audioPlayer.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: voiceState.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic, size: 64),
                        const SizedBox(height: 16),
                        const Text('Start voice conversation'),
                        const SizedBox(height: 8),
                        Text(
                          'Press mic to record',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: voiceState.messages.length,
                    itemBuilder: (context, index) {
                      final message = voiceState.messages[index];
                      final isUser = message['sender'] == 'user';

                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue[600]
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Audio player for AI responses
                                if (!isUser &&
                                    message['message_type'] == 'voice' &&
                                    message.containsKey('audio_base64'))
                                  _VoicePlayButton(
                                    audioBase64: message['audio_base64'],
                                    audioPlayer: audioPlayer,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Recording indicator
          if (voiceState.isRecording)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Recording...'),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (voiceState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          // Record button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton(
              onPressed: voiceState.isLoading
                  ? null
                  : () => _handleRecording(),
              backgroundColor: isRecording ? Colors.red : Colors.blue,
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRecording() async {
    if (isRecording) {
      // Stop recording
      final path = await audioRecorder.stop();
      setState(() {
        isRecording = false;
        recordingPath = path;
      });

      // Send voice message
      if (recordingPath != null) {
        await ref.read(voiceProvider.notifier).sendVoiceMessage(
          conversationId: widget.conversationId,
          audioPath: recordingPath!,
        );

        recordingPath = null;
      }
    } else {
      // Start recording
      if (await audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();

final path =
    '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

await audioRecorder.start(
  const RecordConfig(),
  path: path,
);
        setState(() {
          isRecording = true;
        });
      }
    }
  }
}

class _VoicePlayButton extends StatefulWidget {
  final String audioBase64;
  final AudioPlayer audioPlayer;

  const _VoicePlayButton({
    required this.audioBase64,
    required this.audioPlayer,
  });

  @override
  State<_VoicePlayButton> createState() => _VoicePlayButtonState();
}

class _VoicePlayButtonState extends State<_VoicePlayButton> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayback,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            isPlaying ? 'Playing...' : 'Play audio',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback() async {
  try {
    if (isPlaying) {
      await widget.audioPlayer.stop();
      setState(() => isPlaying = false);
      return;
    }

    // Decode base64
    final bytes = base64Decode(widget.audioBase64);

    // Temporary folder
    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    // Save audio
    await file.writeAsBytes(bytes);

    // Play
    await widget.audioPlayer.setFilePath(file.path);

    await widget.audioPlayer.play();

    setState(() {
      isPlaying = true;
    });

    widget.audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      }
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Playback Error: $e"),
      ),
    );
  }
}
}