import 'package:equatable/equatable.dart';

enum ChatFilter { all, unread }

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatConversations extends ChatEvent {
  const LoadChatConversations();
}

class FilterChatConversations extends ChatEvent {
  final ChatFilter filter;
  const FilterChatConversations(this.filter);

  @override
  List<Object?> get props => [filter];
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
