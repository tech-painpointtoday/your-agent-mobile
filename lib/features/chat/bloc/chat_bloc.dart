import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/chat_booking.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _searchService = DependencyInjection.chatSearchService;

  ChatBloc() : super(const ChatInitial()) {
    on<LoadChatConversations>(_onLoadChatConversations);
    on<FilterChatConversations>(_onFilterChatConversations);
    on<SearchChatConversations>(_onSearchChatConversations);
    on<SaveRecentSearch>(_onSaveRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
  }

  Future<void> _onLoadChatConversations(
    LoadChatConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final authRepo = DependencyInjection.authRepository;
      if (!authRepo.isAuthenticated) {
        emit(
          const ChatLoaded(
            allConversations: [],
            filteredConversations: [],
            recentSearches: [],
          ),
        );
        return;
      }

      final role = authRepo.currentRole == UserRole.agent ? 'agent' : 'agency';
      final rawBookings = await DependencyInjection.chatApiService
          .getUnreadBookings(role: role);

      final conversations = rawBookings
          .map((json) => ChatBooking.fromJson(json))
          .toList();

      // Add a mock support chat for demonstration
      final mockSupportChat = ChatBooking(
        id: -1,
        participantName: 'YourAgent Support',
        lastMessage: 'สวัสดีครับ มีอะไรให้เราช่วยไหมครับ?',
        unreadCount: 1,
        lastActiveAt: DateTime.now(),
        avatarUrl: null,
      );

      final combinedConversations = [mockSupportChat, ...conversations];

      final recentSearches = await _searchService.getRecentSearches();

      emit(
        ChatLoaded(
          allConversations: combinedConversations,
          filteredConversations: combinedConversations,
          recentSearches: recentSearches,
        ),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onFilterChatConversations(
    FilterChatConversations event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final filtered = _applyFilterAndSearch(
        currentState.allConversations,
        event.filter,
        currentState.searchQuery,
      );
      emit(
        currentState.copyWith(
          filteredConversations: filtered,
          currentFilter: event.filter,
        ),
      );
    }
  }

  void _onSearchChatConversations(
    SearchChatConversations event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final filtered = _applyFilterAndSearch(
        currentState.allConversations,
        currentState.currentFilter,
        event.query,
      );
      emit(
        currentState.copyWith(
          filteredConversations: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }

  Future<void> _onSaveRecentSearch(
    SaveRecentSearch event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      await _searchService.saveSearch(event.query);
      final recentSearches = await _searchService.getRecentSearches();
      emit(currentState.copyWith(recentSearches: recentSearches));
    }
  }

  Future<void> _onClearRecentSearches(
    ClearRecentSearches event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      await _searchService.clearRecentSearches();
      emit(currentState.copyWith(recentSearches: []));
    }
  }

  List<ChatBooking> _applyFilterAndSearch(
    List<ChatBooking> conversations,
    ChatFilter filter,
    String query,
  ) {
    var result = conversations;

    // Apply Filter
    if (filter == ChatFilter.unread) {
      result = result.where((c) => c.unreadCount > 0).toList();
    }

    // Apply Search
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result
          .where(
            (c) =>
                c.participantName.toLowerCase().contains(lowerQuery) ||
                (c.lastMessage?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .toList();
    }

    return result;
  }
}
