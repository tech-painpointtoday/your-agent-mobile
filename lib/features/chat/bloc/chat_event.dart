import 'package:equatable/equatable.dart';

enum ChatStatusFilter { all, unread }

enum ChatTypeFilter { all, booking, inquiry }

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatConversations extends ChatEvent {
  const LoadChatConversations();
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
