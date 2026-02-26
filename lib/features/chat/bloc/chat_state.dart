import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_booking.dart';
import 'chat_event.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatBooking> allConversations;
  final List<ChatBooking> filteredConversations;
  final ChatStatusFilter statusFilter;
  final ChatTypeFilter typeFilter;
  final String searchQuery;
  final List<String> recentSearches;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const ChatLoaded({
    required this.allConversations,
    required this.filteredConversations,
    this.statusFilter = ChatStatusFilter.all,
    this.typeFilter = ChatTypeFilter.all,
    this.searchQuery = '',
    this.recentSearches = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  ChatLoaded copyWith({
    List<ChatBooking>? allConversations,
    List<ChatBooking>? filteredConversations,
    ChatStatusFilter? statusFilter,
    ChatTypeFilter? typeFilter,
    String? searchQuery,
    List<String>? recentSearches,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return ChatLoaded(
      allConversations: allConversations ?? this.allConversations,
      filteredConversations:
          filteredConversations ?? this.filteredConversations,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      recentSearches: recentSearches ?? this.recentSearches,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    allConversations,
    filteredConversations,
    statusFilter,
    typeFilter,
    searchQuery,
    recentSearches,
    currentPage,
    lastPage,
    isLoadingMore,
  ];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
