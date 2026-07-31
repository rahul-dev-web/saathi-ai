import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import '../../../core/api_client.dart';

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>(
  (ref) => VoiceNotifier(ref.watch(apiClientProvider)),
);

class VoiceState {
  final bool isLoading;
  final bool isRecording;
  final List<Map<String, dynamic>> messages;
  final String? error;

  VoiceState({
    this.isLoading = false,
    this.isRecording = false,
    this.messages = const [],
    this.error,
  });

  VoiceState copyWith({
    bool? isLoading,
    bool? isRecording,
    List<Map<String, dynamic>>? messages,
    String? error,
  }) {
    return VoiceState(
      isLoading: isLoading ?? this.isLoading,
      isRecording: isRecording ?? this.isRecording,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  final ApiClient _apiClient;

  VoiceNotifier(this._apiClient) : super(VoiceState());

  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get(
        '/chat/messages/$conversationId',
      );

      final messages = List<Map<String, dynamic>>.from(
        response.data['messages'] ?? []
      );

      state = state.copyWith(
        isLoading: false,
        messages: messages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendVoiceMessage({
    required String conversationId,
    required String audioPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Read audio file
      final audioFile = File(audioPath);
      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      // Send to backend
      final response = await _apiClient.post(
        '/voice/message',
        data: {
          'conversation_id': conversationId,
          'audio_base64': audioBase64,
          'message_type': 'voice',
        },
      );

      final userMsg = Map<String, dynamic>.from(response.data['user_message']);
      final aiMsg = Map<String, dynamic>.from(response.data['ai_message']);

      final updatedMessages = [
        ...state.messages,
        userMsg,
        aiMsg,
      ];

      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}