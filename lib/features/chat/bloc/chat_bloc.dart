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
    on<FilterChatStatus>(_onFilterChatStatus);
    on<FilterChatType>(_onFilterChatType);
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

      const perPage = 10;
      final bookingResponse = await DependencyInjection.chatApiService
          .getChats(page: 1, perPage: perPage);

      // Load inquiry chats (property inquiries) and convert them into synthetic
      // ChatMessage entries, then merge with booking messages.
      // If this endpoint fails, we still show booking chats.
      List<ChatMessage> inquiryMessages = [];
      try {
        inquiryMessages = await DependencyInjection.chatApiService
            .getInquiryConversations();
      } catch (_) {
        inquiryMessages = [];
      }

      final allMessages = <ChatMessage>[
        ...bookingResponse.messages,
        ...inquiryMessages,
      ];

      final conversations = _conversationsFromMessages(allMessages);
      final pagination = bookingResponse.pagination;
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
      const perPage = 10;
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
        currentState.statusFilter,
        currentState.typeFilter,
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
    final byKey = <String, ChatBooking>{
      for (final c in existing)
        _conversationKey(c.type, c.id): c,
    };
    for (final c in incoming) {
      byKey[_conversationKey(c.type, c.id)] = c;
    }
    final list = byKey.values.toList()
      ..sort(
        (a, b) => (b.lastActiveAt ?? DateTime(0)).compareTo(
          a.lastActiveAt ?? DateTime(0),
        ),
      );
    return list;
  }

  String _conversationKey(ChatConversationType type, int id) =>
      '${type.name}-$id';

  /// Group messages by booking_id (booking chats) or property_inquiry_id
  /// (inquiry chats) and build ChatBooking list (newest first).
  List<ChatBooking> _conversationsFromMessages(List<ChatMessage> messages) {
    final byConversation = <String, List<ChatMessage>>{};
    for (final m in messages) {
      int? id;
      ChatConversationType type = ChatConversationType.booking;

      // Prefer inquiry id when present, so property inquiries are correctly
      // classified even if bookingId is also populated by legacy parsing.
      if (m.propertyInquiryId != null && m.propertyInquiryId! > 0) {
        id = m.propertyInquiryId!;
        type = ChatConversationType.inquiry;
      } else if (m.bookingId != null && m.bookingId! > 0) {
        id = m.bookingId!;
        type = ChatConversationType.booking;
      }

      if (id == null) continue;

      final key = _conversationKey(type, id);
      byConversation.putIfAbsent(key, () => []).add(m);
    }
    final list = <ChatBooking>[];
    for (final entry in byConversation.entries) {
      final key = entry.key;
      final parts = key.split('-');
      final type = parts.first == ChatConversationType.inquiry.name
          ? ChatConversationType.inquiry
          : ChatConversationType.booking;

      final bookingMessages = entry.value
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
      final latest = bookingMessages.first;
      String participantName = latest.senderName ?? 'Unknown';
      if (latest.senderType == SenderType.agent) {
        final fromOther = bookingMessages
            .where(
              (m) =>
                  m.senderType != SenderType.agent &&
                  (m.senderName ?? '').isNotEmpty,
            )
            .map((m) => m.senderName!);
        if (fromOther.isNotEmpty) {
          participantName = fromOther.first;
        }
      }
      final unreadCount = bookingMessages
          .where((m) => m.senderType != SenderType.agent && !m.isRead)
          .length;
      final id = (type == ChatConversationType.inquiry
              ? bookingMessages.first.propertyInquiryId
              : bookingMessages.first.bookingId) ??
          0;
      if (id <= 0) continue;
      list.add(
        ChatBooking(
          id: id,
          participantName: participantName,
          lastMessage: _formatLastMessage(latest),
          unreadCount: unreadCount,
          lastActiveAt: latest.createdAt,
          avatarUrl: null,
          type: type,
          inquiryId:
              type == ChatConversationType.inquiry ? id : null,
        ),
      );
    }
    list.sort(
      (a, b) => (b.lastActiveAt ?? DateTime(0)).compareTo(
        a.lastActiveAt ?? DateTime(0),
      ),
    );
    return list;
  }

  void _onFilterChatStatus(
    FilterChatStatus event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final filtered = _applyFilterAndSearch(
        currentState.allConversations,
        event.status,
        currentState.typeFilter,
        currentState.searchQuery,
      );
      emit(
        currentState.copyWith(
          filteredConversations: filtered,
          statusFilter: event.status,
        ),
      );
    }
  }

  void _onFilterChatType(
    FilterChatType event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final filtered = _applyFilterAndSearch(
        currentState.allConversations,
        currentState.statusFilter,
        event.type,
        currentState.searchQuery,
      );
      emit(
        currentState.copyWith(
          filteredConversations: filtered,
          typeFilter: event.type,
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
        currentState.statusFilter,
        currentState.typeFilter,
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
    ChatStatusFilter statusFilter,
    ChatTypeFilter typeFilter,
    String query,
  ) {
    var result = conversations;

    // Apply status filter (all / unread)
    if (statusFilter == ChatStatusFilter.unread) {
      result = result.where((c) => c.unreadCount > 0).toList();
    }

    // Apply type filter (all / booking / inquiry)
    if (typeFilter == ChatTypeFilter.booking) {
      result =
          result.where((c) => c.type == ChatConversationType.booking).toList();
    } else if (typeFilter == ChatTypeFilter.inquiry) {
      result =
          result.where((c) => c.type == ChatConversationType.inquiry).toList();
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

  String _formatLastMessage(ChatMessage message) {
    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      if (message.senderType == SenderType.agent ||
          message.senderType == SenderType.staff) {
        return "You: sent an image";
      } else {
        return "Have an image message";
      }
    }
    return message.message;
  }
}
