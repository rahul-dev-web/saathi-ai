import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref.watch(apiClientProvider)),
);

class HomeState {
  final bool isLoading;
  final List<Map<String, dynamic>> conversations;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.conversations = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? conversations,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ApiClient _apiClient;

  HomeNotifier(this._apiClient) : super(HomeState()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiClient.get(
        '/chat/conversations',
      );

      final convs = List<Map<String, dynamic>>.from(
        response.data['conversations'] as List? ?? [],
      );

      state = state.copyWith(
        isLoading: false,
        conversations: convs,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>?> createConversation(String title) async {
    try {
      final response = await _apiClient.post(
        '/chat/conversation',
        data: {
          'title': title,
        },
      );

      final newConv = Map<String, dynamic>.from(response.data);

      state = state.copyWith(
        conversations: [
          ...state.conversations,
          newConv,
        ],
      );
      return newConv;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      return null;
    }
  }
}
