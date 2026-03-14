import 'package:equatable/equatable.dart';

enum ChatStatusFilter { all, unread }

enum ChatTypeFilter { all, booking, inquiry }

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatConversations extends ChatEvent {
  /// Optional search query; when set, APIs are called with q.
  final String? query;
  /// When provided, unread_only is sent to API (true when unread, false when all).
  final ChatStatusFilter? statusFilter;
  /// When provided, only the selected type is fetched: all=both APIs, booking=getChats only, inquiry=getInquiryConversations only.
  final ChatTypeFilter? typeFilter;
  const LoadChatConversations({
    this.query,
    this.statusFilter,
    this.typeFilter,
  });
  @override
  List<Object?> get props => [query, statusFilter, typeFilter];
}

class LoadMoreChatConversations extends ChatEvent {
  const LoadMoreChatConversations();
}

class FilterChatStatus extends ChatEvent {
  final ChatStatusFilter status;
  const FilterChatStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterChatType extends ChatEvent {
  final ChatTypeFilter type;
  const FilterChatType(this.type);

  @override
  List<Object?> get props => [type];
}

class SearchChatConversations extends ChatEvent {
  final String query;
  const SearchChatConversations(this.query);

  @override
  List<Object?> get props => [query];
}

class SaveRecentSearch extends ChatEvent {
  final String query;
  const SaveRecentSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearRecentSearches extends ChatEvent {
  const ClearRecentSearches();
}
