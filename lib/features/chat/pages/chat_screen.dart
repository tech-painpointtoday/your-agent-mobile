import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_booking.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_search_bar.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()..add(const LoadChatConversations()),
      child: const _ChatScreenContent(),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  const _ChatScreenContent();

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<ChatBloc>().state;
    if (state is! ChatLoaded || !state.hasMore || state.isLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ChatBloc>().add(const LoadMoreChatConversations());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.baseDarkGrey,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          l10n.conversation_title,
          style: GoogleFonts.anuphan(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: AppColors.primary,
        onRefresh: () async {
          final bloc = context.read<ChatBloc>();
          bloc.add(const LoadChatConversations());
          await bloc.stream
              .skip(1)
              .where((s) => s is ChatLoaded || s is ChatError)
              .first
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () => bloc.state,
              );
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (!_isSearchFocused) _FilterSection(l10n: l10n),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  _isSearchFocused ? 12 : 0,
                  16,
                  16,
                ),
                child: AppSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: l10n.search_messages_hint,
                  onChanged: (query) {
                    context.read<ChatBloc>().add(
                      SearchChatConversations(query),
                    );
                  },
                ),
              ),
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  final query = state is ChatLoaded ? state.searchQuery : '';
                  final recentSearches = state is ChatLoaded
                      ? state.recentSearches
                      : <String>[];

                  if (_isSearchFocused && query.isEmpty) {
                    return _RecentSearchSection(
                      l10n: l10n,
                      recentSearches: recentSearches,
                      onItemTap: (text) {
                        _searchController.text = text;
                        // Trigger search manually when tapping a recent item
                        context.read<ChatBloc>().add(
                          SearchChatConversations(text),
                        );
                        // Close keyboard
                        _searchFocusNode.unfocus();
                      },
                      onClear: () {
                        context.read<ChatBloc>().add(
                          const ClearRecentSearches(),
                        );
                      },
                    );
                  }
                  return _ConversationList(l10n: l10n);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchSection extends StatelessWidget {
  final AppLocalizations l10n;
  final List<String> recentSearches;
  final Function(String) onItemTap;
  final VoidCallback onClear;

  const _RecentSearchSection({
    required this.l10n,
    required this.recentSearches,
    required this.onItemTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.basePaleGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.recent_search,
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseDarkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.cancel,
                  color: AppColors.baseGrey,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentSearches.map((text) => _buildRecentItem(text)),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String text) {
    return InkWell(
      onTap: () => onItemTap(text),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppColors.baseGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _FilterSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final currentFilter = state is ChatLoaded
            ? state.currentFilter
            : ChatFilter.all;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              _FilterChip(
                label: l10n.all,
                isSelected: currentFilter == ChatFilter.all,
                onTap: () => context.read<ChatBloc>().add(
                  const FilterChatConversations(ChatFilter.all),
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: l10n.unread,
                isSelected: currentFilter == ChatFilter.unread,
                onTap: () => context.read<ChatBloc>().add(
                  const FilterChatConversations(ChatFilter.unread),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(color: AppColors.baseLightGrey, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.anuphan(
            color: isSelected ? AppColors.white : AppColors.baseDarkGrey,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  final AppLocalizations l10n;
  const _ConversationList({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 32,
              ),
            ),
          );
        }

        if (state is ChatError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        if (state is ChatLoaded) {
          final currentFilter = state.currentFilter;
          final conversations = state.filteredConversations;
          final hasMore = state.hasMore;
          final isLoadingMore = state.isLoadingMore;

          if (conversations.isEmpty && !isLoadingMore) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 64,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/YA_Illustration_EmptyState_NoMessage.png',
                      width: 180,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentFilter == ChatFilter.unread
                          ? l10n.empty_chat_message_unread
                          : l10n.empty_chat_message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  return _ChatSessionTile(
                    conversation: conversations[index],
                    l10n: l10n,
                  );
                },
              ),
              if (hasMore && isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ChatSessionTile extends StatelessWidget {
  final ChatBooking conversation;
  final AppLocalizations l10n;

  const _ChatSessionTile({required this.conversation, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final chatBloc = context.read<ChatBloc>();
        final currentState = chatBloc.state;
        if (currentState is ChatLoaded && currentState.searchQuery.isNotEmpty) {
          chatBloc.add(SaveRecentSearch(currentState.searchQuery));
        }

        final routePath = conversation.type == ChatConversationType.inquiry
            ? '/chat/inquiry/${conversation.id}'
            : '/chat/${conversation.id}';

        context
            .push(
              routePath,
              extra: conversation.participantName,
            )
            .then((_) {
              if (context.mounted) {
                context.read<ChatBloc>().add(const LoadChatConversations());
              }
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.anuphan(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.baseBlack,
                          ),
                        ),
                      ),
                      if (conversation.lastActiveAt != null)
                        Text(
                          _formatDate(conversation.lastActiveAt!),
                          style: GoogleFonts.anuphan(
                            fontSize: 12,
                            color: AppColors.baseGrey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (conversation.lastMessage?.isNotEmpty ?? false)
                              ? conversation.lastMessage!
                              : l10n.no_messages,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.anuphan(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: conversation.unreadCount > 0
                                ? AppColors.baseBlack
                                : AppColors.baseDarkGrey,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.supportRedDeep,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.basePaleGrey,
      ),
      child: ClipOval(
        child:
            conversation.avatarUrl != null && conversation.avatarUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: conversation.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final initial = conversation.participantName.isNotEmpty
        ? conversation.participantName[0].toUpperCase()
        : '?';
    return Container(
      color: AppColors.basePaleGrey,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.anuphan(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final chatDate = DateTime(local.year, local.month, local.day);

    if (chatDate == today) {
      return '${DateFormat('HH:mm').format(local)} ${l10n.time_unit_th}';
    } else if (chatDate == yesterday) {
      return l10n.yesterday;
    } else {
      return DateFormat('dd/MM/yyyy').format(local);
    }
  }
}
