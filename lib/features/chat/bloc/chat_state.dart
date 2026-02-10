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
  final ChatFilter currentFilter;
  final String searchQuery;
  final List<String> recentSearches;

  const ChatLoaded({
    required this.allConversations,
    required this.filteredConversations,
    this.currentFilter = ChatFilter.all,
    this.searchQuery = '',
    this.recentSearches = const [],
  });

  ChatLoaded copyWith({
    List<ChatBooking>? allConversations,
    List<ChatBooking>? filteredConversations,
    ChatFilter? currentFilter,
    String? searchQuery,
    List<String>? recentSearches,
  }) {
    return ChatLoaded(
      allConversations: allConversations ?? this.allConversations,
      filteredConversations:
          filteredConversations ?? this.filteredConversations,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  List<Object?> get props => [
    allConversations,
    filteredConversations,
    currentFilter,
    searchQuery,
    recentSearches,
  ];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
