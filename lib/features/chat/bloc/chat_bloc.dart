import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/chat_booking.dart';
import '../../../domain/entities/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _searchService = DependencyInjection.chatSearchService;

  ChatBloc() : super(const ChatInitial()) {
    on<LoadChatConversations>(_onLoadChatConversations);
    on<LoadMoreChatConversations>(_onLoadMoreChatConversations);
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

      const perPage = 15;
      final response = await DependencyInjection.chatApiService.getChats(
        page: 1,
        perPage: perPage,
      );

      final conversations = _conversationsFromMessages(response.messages);
      final pagination = response.pagination;
      final recentSearches = await _searchService.getRecentSearches();

      emit(
        ChatLoaded(
          allConversations: conversations,
          filteredConversations: conversations,
          recentSearches: recentSearches,
          currentPage: pagination.currentPage,
          lastPage: pagination.lastPage,
        ),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMoreChatConversations(
    LoadMoreChatConversations event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      const perPage = 15;
      final nextPage = currentState.currentPage + 1;
      final response = await DependencyInjection.chatApiService.getChats(
        page: nextPage,
        perPage: perPage,
      );

      final newConversations = _conversationsFromMessages(response.messages);
      final merged = _mergeConversations(
        currentState.allConversations,
        newConversations,
      );
      final filtered = _applyFilterAndSearch(
        merged,
        currentState.currentFilter,
        currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          allConversations: merged,
          filteredConversations: filtered,
          currentPage: response.pagination.currentPage,
          lastPage: response.pagination.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Merge new conversations into existing by booking id (new overwrites for same id).
  List<ChatBooking> _mergeConversations(
    List<ChatBooking> existing,
    List<ChatBooking> incoming,
  ) {
    final byId = <int, ChatBooking>{
      for (final c in existing) c.id: c,
    };
    for (final c in incoming) {
      byId[c.id] = c;
    }
    final list = byId.values.toList()
      ..sort(
        (a, b) =>
            (b.lastActiveAt ?? DateTime(0))
                .compareTo(a.lastActiveAt ?? DateTime(0)),
      );
    return list;
  }

  /// Group messages by booking_id and build ChatBooking list (newest first).
  List<ChatBooking> _conversationsFromMessages(List<ChatMessage> messages) {
    final byBooking = <int, List<ChatMessage>>{};
    for (final m in messages) {
      final bid = m.bookingId ?? 0;
      if (bid <= 0) continue;
      byBooking.putIfAbsent(bid, () => []).add(m);
    }
    final list = <ChatBooking>[];
    for (final entry in byBooking.entries) {
      final bookingMessages = entry.value
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      final latest = bookingMessages.first;
      String participantName = latest.senderName ?? 'Unknown';
      if (latest.senderType == SenderType.agent) {
        final fromOther = bookingMessages
            .where((m) => m.senderType != SenderType.agent && (m.senderName ?? '').isNotEmpty)
            .map((m) => m.senderName!);
        if (fromOther.isNotEmpty) {
          participantName = fromOther.first;
        }
      }
      final unreadCount = bookingMessages
          .where((m) =>
              m.senderType != SenderType.agent && !m.isRead)
          .length;
      list.add(
        ChatBooking(
          id: entry.key,
          participantName: participantName,
          lastMessage: latest.message,
          unreadCount: unreadCount,
          lastActiveAt: latest.createdAt,
          avatarUrl: null,
        ),
      );
    }
    list.sort((a, b) =>
        (b.lastActiveAt ?? DateTime(0)).compareTo(a.lastActiveAt ?? DateTime(0)));
    return list;
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
