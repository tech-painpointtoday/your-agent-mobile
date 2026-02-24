import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_message.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/modals/app_image_picker_bottom_sheet.dart';
import '../../../widgets/modals/app_call_bottom_sheet.dart';

class MessageScreen extends StatelessWidget {
  final int bookingId;
  final String participantName;
  final String participantPhone;
  final bool isStaff;

  const MessageScreen({
    super.key,
    required this.bookingId,
    required this.participantName,
    required this.participantPhone,
    this.isStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MessageBloc(isStaff: isStaff)..add(LoadMessages(bookingId)),
      child: _MessageScreenContent(
        bookingId: bookingId,
        participantName: participantName,
        participantPhone: participantPhone,
      ),
    );
  }
}

class _MessageScreenContent extends StatefulWidget {
  final int bookingId;
  final String participantName;
  final String participantPhone;

  const _MessageScreenContent({
    required this.bookingId,
    required this.participantName,
    required this.participantPhone,
  });

  @override
  State<_MessageScreenContent> createState() => _MessageScreenContentState();
}

class _MessageScreenContentState extends State<_MessageScreenContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _searchVisible = false;
  bool _isSearchFocused = false;
  List<int> _matchIndices = [];
  int _currentMatchIndex = 0;
  static const double _estimatedItemHeight = 120;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_isSearchFocused != _searchFocusNode.hasFocus) {
        setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateSearchMatches(List<ChatMessage> messages, String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _matchIndices = [];
        _currentMatchIndex = 0;
      });
      return;
    }
    final lower = query.trim().toLowerCase();
    final indices = <int>[];
    for (var i = 0; i < messages.length; i++) {
      final text = messages[i].message;
      if (text.startsWith('http')) continue; // skip image-only
      if (text.toLowerCase().contains(lower)) indices.add(i);
    }
    setState(() {
      _matchIndices = indices;
      _currentMatchIndex = indices.isEmpty ? 0 : 0;
    });
    if (indices.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMatch(0));
    }
  }

  void _scrollToMatch(int matchListIndex) {
    if (_matchIndices.isEmpty || !_scrollController.hasClients) return;
    final messageIndex = _matchIndices[matchListIndex];
    final offset = (messageIndex * _estimatedItemHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: _searchVisible
          ? _buildSearchOverlayAppBar(context, l10n)
          : AppBar(
              backgroundColor: AppColors.white,
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
                onPressed: () => context.pop(),
              ),
              titleSpacing: 0,
              title: _buildAppBar(context),
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB5E6FF), Color(0xFFF9FDFF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 84,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  'assets/images/home/cloud.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 120 / 360,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: BlocConsumer<MessageBloc, MessageState>(
                      listener: (context, state) {
                        if (state is MessageLoaded && !_searchVisible) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is MessageLoading) {
                          return const Center(
                            child: SpinKitFadingCircle(
                              color: AppColors.primary,
                              size: 32,
                            ),
                          );
                        }

                        if (state is MessageError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          );
                        }

                        if (state is MessageLoaded) {
                          final messages = state.messages;
                          if (messages.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.no_messages,
                                style: GoogleFonts.anuphan(
                                  color: AppColors.baseGrey,
                                ),
                              ),
                            );
                          }

                          final searchQuery = _searchController.text.trim();
                          final currentMessageIndex =
                              _matchIndices.isNotEmpty &&
                                  _currentMatchIndex < _matchIndices.length
                              ? _matchIndices[_currentMatchIndex]
                              : -1;

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe =
                                  message.senderType == SenderType.agent ||
                                  message.senderType == SenderType.staff;

                              final localCreatedAt = message.createdAt
                                  ?.toLocal();
                              bool showDate = false;
                              if (index == 0) {
                                showDate = true;
                              } else {
                                final prevMessage = messages[index - 1];
                                final prevLocal = prevMessage.createdAt
                                    ?.toLocal();
                                if (localCreatedAt != null &&
                                    prevLocal != null) {
                                  final currentDay = DateTime(
                                    localCreatedAt.year,
                                    localCreatedAt.month,
                                    localCreatedAt.day,
                                  );
                                  final prevDay = DateTime(
                                    prevLocal.year,
                                    prevLocal.month,
                                    prevLocal.day,
                                  );
                                  if (currentDay != prevDay) {
                                    showDate = true;
                                  }
                                }
                              }

                              // Show time only on last message of same hour+minute group
                              final nextCreatedAt = index < messages.length - 1
                                  ? messages[index + 1].createdAt?.toLocal()
                                  : null;
                              final sameMinuteAsNext =
                                  localCreatedAt != null &&
                                  nextCreatedAt != null &&
                                  localCreatedAt.hour == nextCreatedAt.hour &&
                                  localCreatedAt.minute == nextCreatedAt.minute;
                              final showTime = !sameMinuteAsNext;

                              return Column(
                                children: [
                                  if (showDate && localCreatedAt != null)
                                    _DateHeader(date: localCreatedAt),
                                  _ChatBubble(
                                    message: message.message,
                                    imageUrl: message.imageUrl,
                                    isMe: isMe,
                                    isRead: message.isRead,
                                    time: localCreatedAt != null
                                        ? DateFormat(
                                            'HH:mm',
                                          ).format(localCreatedAt)
                                        : '',
                                    showTime: showTime,
                                    searchQuery: searchQuery.isEmpty
                                        ? null
                                        : searchQuery,
                                    isCurrentMatch:
                                        index == currentMessageIndex,
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  _buildInputBar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.basePaleGrey,
          ),
          child: Center(
            child: Text(
              widget.participantName.isNotEmpty
                  ? widget.participantName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.anuphan(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.participantName,
            style: GoogleFonts.anuphan(
              color: AppColors.baseBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _CircleIconButton(
          iconPath: 'assets/icons/search.svg',
          onPressed: () {
            setState(() {
              _searchVisible = true;
              _searchController.clear();
              _matchIndices = [];
              _currentMatchIndex = 0;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          iconPath: 'assets/icons/phone.svg',
          onPressed: () {
            AppCallBottomSheet.show(
              context: context,
              options: [CallOption(label: '', phone: widget.participantPhone)],
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  PreferredSizeWidget _buildSearchOverlayAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return PreferredSize(
      preferredSize: Size(
        MediaQuery.of(context).size.width,
        kToolbarHeight + MediaQuery.of(context).padding.top,
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 12,
          right: 8,
          bottom: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isSearchFocused
                      ? [
                          BoxShadow(
                            color: Color(0x0C1743C7),
                            blurRadius: 0,
                            offset: Offset(0, 0),
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (query) {
                    final state = context.read<MessageBloc>().state;
                    if (state is MessageLoaded) {
                      _updateSearchMatches(state.messages, query);
                    }
                  },
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseBlack,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.search_messages_hint,
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 14,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.6,
                      ),
                    ),
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.scaleDown,
                        colorFilter: const ColorFilter.mode(
                          AppColors.baseDarkGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_matchIndices.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '${_currentMatchIndex + 1} / ${_matchIndices.length}',
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  color: AppColors.baseDarkGrey,
                ),
              ),
              SizedBox(width: 16),
              IconButton(
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: SvgPicture.asset(
                  'assets/icons/chevron-up.svg',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _currentMatchIndex =
                        (_currentMatchIndex - 1 + _matchIndices.length) %
                        _matchIndices.length;
                  });
                  _scrollToMatch(_currentMatchIndex);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              ),
              SizedBox(width: 24),
              IconButton(
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: SvgPicture.asset(
                  'assets/icons/chevron-down.svg',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _currentMatchIndex =
                        (_currentMatchIndex + 1) % _matchIndices.length;
                  });
                  _scrollToMatch(_currentMatchIndex);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              ),
            ] else if (_searchController.text.trim().isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '0',
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  color: AppColors.baseGrey,
                ),
              ),
            ],
            SizedBox(width: _matchIndices.isNotEmpty ? 24 : 8),
            IconButton(
              style: IconButton.styleFrom(
                side: BorderSide(color: AppColors.baseGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: SvgPicture.asset(
                'assets/icons/x.svg',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseDarkGrey,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                setState(() {
                  _searchVisible = false;
                  _searchController.clear();
                  _matchIndices = [];
                  _currentMatchIndex = 0;
                });
                _searchFocusNode.unfocus();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.baseLightGrey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.baseBlack,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.type_message_hint,
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          fontSize: 14,
                        ),
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/camera.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.scaleDown,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      AppImagePickerBottomSheet.show(
                        context: context,
                        onImagesPicked: (paths) {
                          if (paths.isNotEmpty) {
                            for (final path in paths) {
                              context.read<MessageBloc>().add(
                                SendMessage(
                                  bookingId: widget.bookingId,
                                  message: '',
                                  image: File(path),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              final isSending = state is MessageLoaded && state.isSending;

              return InkWell(
                onTap: isSending
                    ? null
                    : () {
                        final text = _messageController.text.trim();
                        if (text.isNotEmpty) {
                          context.read<MessageBloc>().add(
                            SendMessage(
                              bookingId: widget.bookingId,
                              message: text,
                            ),
                          );
                          _messageController.clear();
                        }
                      },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E4ABF),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: isSending
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      : Center(
                          child: SvgPicture.asset(
                            'assets/icons/direction-up-right-2.svg',
                            width: 16,
                            height: 16,
                            fit: BoxFit.scaleDown,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.iconPath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.basePaleGrey,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 16,
          height: 16,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            AppColors.baseBlack,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label = '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    // date is already in local time when passed from parent
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      label = l10n.today;
    } else if (checkDate == yesterday) {
      label = l10n.yesterday;
    } else {
      label = DateFormat('dd/MM/yyyy').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 12,
            color: AppColors.baseGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final String? imageUrl;
  final bool isMe;
  final bool isRead;
  final String time;
  final bool showTime;
  final String? searchQuery;
  final bool isCurrentMatch;

  const _ChatBubble({
    required this.message,
    this.imageUrl,
    required this.isMe,
    this.isRead = false,
    required this.time,
    this.showTime = true,
    this.searchQuery,
    this.isCurrentMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) _buildStatusRow(l10n, true),
          if (imageUrl != null)
            _buildImageBubble(context)
          else
            _buildTextBubble(context),
          if (!isMe) _buildStatusRow(l10n, false),
        ],
      ),
    );
  }

  Widget _buildStatusRow(AppLocalizations l10n, bool me) {
    // Show time and read/sent only on last message of same-minute group
    if (!showTime) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(left: me ? 0 : 8, right: me ? 8 : 0, bottom: 4),
      child: Column(
        crossAxisAlignment: me
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (me)
            Text(
              isRead ? l10n.read_status : l10n.message_sent,
              style: GoogleFonts.anuphan(
                fontSize: 10,
                color: AppColors.baseGrey,
              ),
            ),
          Text(
            time,
            style: GoogleFonts.anuphan(fontSize: 10, color: AppColors.baseGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(BuildContext context) {
    final textColor = isMe ? Colors.white : AppColors.baseBlack;
    final baseStyle = GoogleFonts.anuphan(
      color: textColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    Widget content;
    if (searchQuery != null &&
        searchQuery!.isNotEmpty &&
        message.toLowerCase().contains(searchQuery!.toLowerCase())) {
      final lowerMessage = message.toLowerCase();
      final lowerQuery = searchQuery!.toLowerCase();
      final spans = <TextSpan>[];
      int start = 0;
      int matchStart;
      while ((matchStart = lowerMessage.indexOf(lowerQuery, start)) != -1) {
        if (matchStart > start) {
          spans.add(
            TextSpan(
              text: message.substring(start, matchStart),
              style: baseStyle,
            ),
          );
        }
        spans.add(
          TextSpan(
            text: message.substring(
              matchStart,
              matchStart + searchQuery!.length,
            ),
            style: baseStyle.copyWith(
              backgroundColor: const Color(0xFFFEF08A), // highlight yellow
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        start = matchStart + searchQuery!.length;
      }
      if (start < message.length) {
        spans.add(TextSpan(text: message.substring(start), style: baseStyle));
      }
      content = RichText(
        text: TextSpan(children: spans, style: baseStyle),
      );
    } else {
      content = Text(message, style: baseStyle);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppColors.supportBlueDark : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        border: isCurrentMatch
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildImageBubble(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: AppColors.basePaleGrey,
            child: const Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
