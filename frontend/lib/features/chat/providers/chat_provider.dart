import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref.watch(apiClientProvider)),
);

class ChatState {
  final bool isLoading;
  final List<Map<String, dynamic>> messages;
  final String? error;

  ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? messages,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiClient _apiClient;

  ChatNotifier(this._apiClient) : super(ChatState());

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

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        '/chat/message',
        data: {
          'conversation_id': conversationId,
          'content': content,
          'message_type': 'text',
        },
      );

      final userMsg = Map<String, dynamic>.from(
  response.data['user_message'],
);

final aiMsg = Map<String, dynamic>.from(
  response.data['ai_message'],
);

final List<Map<String, dynamic>> updatedMessages = [
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