import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final bool isStaff;

  const MessageScreen({
    super.key,
    required this.bookingId,
    required this.participantName,
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
      ),
    );
  }
}

class _MessageScreenContent extends StatefulWidget {
  final int bookingId;
  final String participantName;

  const _MessageScreenContent({
    required this.bookingId,
    required this.participantName,
  });

  @override
  State<_MessageScreenContent> createState() => _MessageScreenContentState();
}

class _MessageScreenContentState extends State<_MessageScreenContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      appBar: AppBar(
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
                        if (state is MessageLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is MessageLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
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

                              bool showDate = false;
                              if (index == 0) {
                                showDate = true;
                              } else {
                                final prevMessage = messages[index - 1];
                                if (message.createdAt != null &&
                                    prevMessage.createdAt != null) {
                                  final currentDay = DateTime(
                                    message.createdAt!.year,
                                    message.createdAt!.month,
                                    message.createdAt!.day,
                                  );
                                  final prevDay = DateTime(
                                    prevMessage.createdAt!.year,
                                    prevMessage.createdAt!.month,
                                    prevMessage.createdAt!.day,
                                  );
                                  if (currentDay != prevDay) {
                                    showDate = true;
                                  }
                                }
                              }

                              return Column(
                                children: [
                                  if (showDate && message.createdAt != null)
                                    _DateHeader(date: message.createdAt!),
                                  _ChatBubble(
                                    message: message.message,
                                    isMe: isMe,
                                    time: message.createdAt != null
                                        ? DateFormat(
                                            'HH:mm',
                                          ).format(message.createdAt!)
                                        : '',
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
          child: CircleAvatar(
            backgroundColor: AppColors.basePaleGrey,
            child: Icon(Icons.person, color: AppColors.baseGrey, size: 24),
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
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          iconPath: 'assets/icons/phone.svg',
          onPressed: () {
            AppCallBottomSheet.show(
              context: context,
              options: [CallOption(label: '', phone: '089-123-4567')],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
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
                            // For mock/demonstration: send a house image URL
                            // In real app, you'd upload and send the returned URL
                            final mockImageUrl =
                                'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=800&q=80';

                            context.read<MessageBloc>().add(
                              SendMessage(
                                bookingId: widget.bookingId,
                                message: mockImageUrl,
                              ),
                            );
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
                      ? Center(
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
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
  final bool isMe;
  final String time;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isImage = message.startsWith('http');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) _buildStatusRow(l10n, true),
          if (isImage)
            _buildImageBubble(context)
          else
            _buildTextBubble(context),
          if (!isMe) _buildStatusRow(l10n, false),
        ],
      ),
    );
  }

  Widget _buildStatusRow(AppLocalizations l10n, bool me) {
    return Padding(
      padding: EdgeInsets.only(left: me ? 0 : 8, right: me ? 8 : 0, bottom: 4),
      child: Column(
        crossAxisAlignment: me
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (me)
            Text(
              l10n.read_status,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: GoogleFonts.anuphan(
          color: isMe ? Colors.white : AppColors.baseBlack,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
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
          imageUrl: message,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: AppColors.basePaleGrey,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
