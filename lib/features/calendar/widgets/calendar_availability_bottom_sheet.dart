import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/widgets/buttons/app_button.dart';
import 'package:yourhome/widgets/inputs/app_text_field.dart';
import 'package:yourhome/widgets/inputs/app_dropdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yourhome/features/calendar/bloc/availability/availability_bloc.dart';
import 'package:yourhome/features/calendar/bloc/availability/availability_event.dart';
import 'package:yourhome/features/calendar/bloc/availability/availability_state.dart';
import 'package:yourhome/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';
import 'package:yourhome/l10n/app_localizations.dart';

enum AvailabilityMode { add, edit }

enum _AvailabilityTimeInputMode { slot, custom }

class _SlotRangeOption {
  final String startTime;
  final String endTime;

  const _SlotRangeOption({required this.startTime, required this.endTime});

  String get key => '$startTime-$endTime';

  /// End time for API (same hour as start, :59) to avoid overlap with next slot. Format H:i.
  String get apiEndTime {
    final parts = startTime.split(':');
    if (parts.length >= 2) return '${parts[0]}:59';
    return endTime;
  }
}

class CalendarAvailabilityBottomSheet extends StatefulWidget {
  final AvailabilityMode mode;
  final DateTime initialDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final bool initialIsAvailable;
  final int? availableTimeId;

  const CalendarAvailabilityBottomSheet({
    super.key,
    required this.mode,
    required this.initialDate,
    this.initialStartTime,
    this.initialEndTime,
    this.initialIsAvailable = true,
    this.availableTimeId,
  });

  static Future<void> show(
    BuildContext context, {
    required AvailabilityMode mode,
    required DateTime initialDate,
    TimeOfDay? initialStartTime,
    TimeOfDay? initialEndTime,
    bool initialIsAvailable = true,
    int? availableTimeId,
  }) {
    final availabilityBloc = context.read<AvailabilityBloc>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: availabilityBloc,
        child: CalendarAvailabilityBottomSheet(
          mode: mode,
          initialDate: initialDate,
          initialStartTime: initialStartTime,
          initialEndTime: initialEndTime,
          initialIsAvailable: initialIsAvailable,
          availableTimeId: availableTimeId,
        ),
      ),
    );
  }

  @override
  State<CalendarAvailabilityBottomSheet> createState() =>
      _CalendarAvailabilityBottomSheetState();
}

class _CalendarAvailabilityBottomSheetState
    extends State<CalendarAvailabilityBottomSheet> {
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late bool _available;
  late _AvailabilityTimeInputMode _timeInputMode;
  final Set<String> _selectedSlotKeys = <String>{};

  late final TextEditingController _dateCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'th');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Default to today if the initial date is in the past
    _selectedDate = widget.initialDate.isBefore(today)
        ? today
        : widget.initialDate;

    _startTime = widget.initialStartTime ?? TimeOfDay.now();

    if (widget.initialEndTime != null) {
      _endTime = widget.initialEndTime;
    } else {
      // Default to 1 hour after start time
      final start = _startTime!;
      _endTime = TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute);
    }

    _available = widget.initialIsAvailable;
    _timeInputMode = _AvailabilityTimeInputMode.slot;

    _dateCtrl = TextEditingController(
      text: _dateFormatter.format(_selectedDate),
    );
    _startCtrl = TextEditingController(text: _formatTime(_startTime));
    _endCtrl = TextEditingController(text: _formatTime(_endTime));

    if (widget.mode == AvailabilityMode.edit &&
        _startTime != null &&
        _endTime != null) {
      final matchedSlot = _toSlotOption(_startTime!, _endTime!);
      if (matchedSlot != null) {
        _selectedSlotKeys.add(matchedSlot.key);
      } else {
        _timeInputMode = _AvailabilityTimeInputMode.custom;
      }
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.brandBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = _dateFormatter.format(_selectedDate);
        _selectedSlotKeys.removeWhere((slotKey) {
          final slot = _allSlots.firstWhere(
            (item) => item.key == slotKey,
            orElse: () => const _SlotRangeOption(startTime: '', endTime: ''),
          );
          if (slot.startTime.isEmpty) return true;
          return _isSlotPast(slot);
        });
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.brandBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startCtrl.text = _formatTime(_startTime);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.brandBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endCtrl.text = _formatTime(_endTime);
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  List<_SlotRangeOption> get _allSlots {
    return List.generate(11, (index) {
      final startHour = 8 + index;
      final endHour = startHour + 1;
      return _SlotRangeOption(
        startTime: '${startHour.toString().padLeft(2, '0')}:00',
        endTime: '${endHour.toString().padLeft(2, '0')}:00',
      );
    });
  }

  _SlotRangeOption? _toSlotOption(TimeOfDay start, TimeOfDay end) {
    // API may return end as same-hour :59 (e.g. 08:59) or next-hour :00 (09:00)
    final sameHourEnd = end.hour == start.hour && end.minute == 59;
    final nextHourEnd = end.hour == start.hour + 1 && end.minute == 0;
    if (!sameHourEnd && !nextHourEnd) return null;
    if (start.minute != 0) return null;
    if (start.hour < 8 || start.hour >= 19) return null;
    final endHour = nextHourEnd ? end.hour : start.hour + 1;
    return _SlotRangeOption(
      startTime: '${start.hour.toString().padLeft(2, '0')}:00',
      endTime: '${endHour.toString().padLeft(2, '0')}:00',
    );
  }

  bool _isSlotPast(_SlotRangeOption slot) {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (!isToday) return false;

    final parts = slot.startTime.split(':');
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return start.isBefore(now);
  }

  /// Slot keys (e.g. "08:00-09:00") already occupied by existing availability on [dateStr].
  /// In edit mode, excludes the slot of the record being edited ([availableTimeId]) so it stays selectable.
  Set<String> _getOccupiedSlotKeys(AvailabilityState state, String dateStr) {
    final occupied = <String>{};
    for (final time in state.times) {
      if (time.date != dateStr) continue;
      if (widget.mode == AvailabilityMode.edit &&
          widget.availableTimeId != null &&
          time.id == widget.availableTimeId) {
        continue; // exclude current record so user can keep same slot
      }
      final parts = time.startTime.split(':');
      if (parts.isEmpty) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      if (hour < 8 || hour >= 19) continue;
      final key =
          '${hour.toString().padLeft(2, '0')}:00-${(hour + 1).toString().padLeft(2, '0')}:00';
      occupied.add(key);
    }
    return occupied;
  }

  List<_SlotRangeOption> get _selectedSlots {
    return _allSlots
        .where((slot) => _selectedSlotKeys.contains(slot.key))
        .toList(growable: false);
  }

  void _toggleSlot(_SlotRangeOption slot, Set<String> occupiedSlotKeys) {
    if (_isSlotPast(slot) || occupiedSlotKeys.contains(slot.key)) return;

    final isEdit = widget.mode == AvailabilityMode.edit;
    setState(() {
      if (isEdit) {
        _selectedSlotKeys
          ..clear()
          ..add(slot.key);
      } else if (_selectedSlotKeys.contains(slot.key)) {
        _selectedSlotKeys.remove(slot.key);
      } else {
        _selectedSlotKeys.add(slot.key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.mode == AvailabilityMode.edit;

    return BlocListener<AvailabilityBloc, AvailabilityState>(
      listenWhen: (previous, current) {
        return (current.action == AvailabilityAction.create ||
                current.action == AvailabilityAction.update) &&
            previous.status == AvailabilityStatus.loading &&
            current.status == AvailabilityStatus.success;
      },
      listener: (context, state) {
        if (state.status == AvailabilityStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.baseLightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              isEdit
                  ? AppLocalizations.of(context).availability_edit_title
                  : AppLocalizations.of(context).availability_add_title,
              style: GoogleFonts.anuphan(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).availability_instruction,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseGrey,
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: AppLocalizations.of(
                      context,
                    ).availability_input_slot_mode,
                    style: _timeInputMode == _AvailabilityTimeInputMode.slot
                        ? AppButtonStyle.primary
                        : AppButtonStyle.outline,
                    height: 42,
                    onPressed: () {
                      setState(() {
                        _timeInputMode = _AvailabilityTimeInputMode.slot;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: AppLocalizations.of(
                      context,
                    ).availability_input_custom_mode,
                    style: _timeInputMode == _AvailabilityTimeInputMode.custom
                        ? AppButtonStyle.primary
                        : AppButtonStyle.outline,
                    height: 42,
                    onPressed: () {
                      setState(() {
                        _timeInputMode = _AvailabilityTimeInputMode.custom;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date field
            AppTextField(
              label: AppLocalizations.of(context).availability_date_label,
              controller: _dateCtrl,
              isRequired: true,
              showCursor: false,
              onTap: _selectDate,
              suffix: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.baseGrey,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_timeInputMode == _AvailabilityTimeInputMode.custom) ...[
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: AppLocalizations.of(
                        context,
                      ).availability_start_time_label,
                      controller: _startCtrl,
                      isRequired: true,
                      showCursor: false,
                      onTap: _selectStartTime,
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/icons/clock.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseGrey,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: AppLocalizations.of(
                        context,
                      ).availability_end_time_label,
                      controller: _endCtrl,
                      showCursor: false,
                      isRequired: true,
                      onTap: _selectEndTime,
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/icons/clock.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseGrey,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              BlocBuilder<AvailabilityBloc, AvailabilityState>(
                buildWhen: (prev, curr) => prev.times != curr.times,
                builder: (context, state) {
                  final dateStr = DateFormat(
                    'yyyy-MM-dd',
                  ).format(_selectedDate);
                  final occupiedSlotKeys = _getOccupiedSlotKeys(state, dateStr);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allSlots.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.4,
                        ),
                    itemBuilder: (context, index) {
                      final slot = _allSlots[index];
                      final selected = _selectedSlotKeys.contains(slot.key);
                      final isPast = _isSlotPast(slot);
                      final isOccupied = occupiedSlotKeys.contains(slot.key);
                      final disabled = isPast || isOccupied;

                      final Color backgroundColor = isPast
                          ? AppColors.basePaleGrey
                          : isOccupied
                          ? AppColors.supportOrangeLight
                          : selected
                          ? AppColors.primary
                          : AppColors.baseWhite;

                      final Color borderColor = isPast
                          ? AppColors.baseLightGrey
                          : isOccupied
                          ? const Color(0xFFDAD3D0)
                          : selected
                          ? AppColors.primary
                          : AppColors.baseLightGrey;

                      final Color textColor = isPast
                          ? AppColors.baseGrey
                          : isOccupied
                          ? const Color(0xFF9D8779)
                          : selected
                          ? AppColors.baseWhite
                          : AppColors.baseDarkGrey;

                      return GestureDetector(
                        onTap: disabled
                            ? null
                            : () => _toggleSlot(slot, occupiedSlotKeys),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${slot.startTime} - ${slot.endTime}',
                            style: GoogleFonts.anuphan(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Status field (only in Edit mode according to image, or always if useful)
            // The image shows "สถานะ" for edit.
            if (isEdit) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(
                        context,
                      ).availability_status_label,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.anuphan(
                            color: AppColors.supportRedDeep,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDropdown<bool>(
                    value: _available,
                    items: const [true, false],
                    itemLabel: (val) => val
                        ? AppLocalizations.of(
                            context,
                          ).availability_status_available
                        : AppLocalizations.of(
                            context,
                          ).availability_status_unavailable,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _available = val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ] else
              const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: AppLocalizations.of(
                      context,
                    ).availability_cancel_button,
                    style: AppButtonStyle.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: isEdit
                        ? AppLocalizations.of(context).availability_save_button
                        : AppLocalizations.of(context).availability_add_button,
                    style: AppButtonStyle.primary,
                    onPressed: () {
                      if (_timeInputMode == _AvailabilityTimeInputMode.slot) {
                        final selectedSlots = _selectedSlots;
                        if (selectedSlots.isEmpty) {
                          StatusDialog.showError(
                            context: context,
                            title: AppLocalizations.of(
                              context,
                            ).availability_invalid_time_title,
                            message: AppLocalizations.of(
                              context,
                            ).availability_select_slot_error,
                          );
                          return;
                        }

                        final hasPastSlot = selectedSlots.any(_isSlotPast);
                        if (hasPastSlot) {
                          StatusDialog.showError(
                            context: context,
                            title: AppLocalizations.of(
                              context,
                            ).availability_invalid_time_title,
                            message: AppLocalizations.of(
                              context,
                            ).availability_past_time_error,
                          );
                          return;
                        }

                        if (isEdit) {
                          final selectedSlot = selectedSlots.first;
                          AppConfirmationBottomSheet.show(
                            context: context,
                            title: AppLocalizations.of(
                              context,
                            ).availability_confirm_edit_title,
                            description: AppLocalizations.of(
                              context,
                            ).availability_confirm_edit_desc,
                            confirmLabel: AppLocalizations.of(
                              context,
                            ).availability_save_button,
                            onConfirm: () {
                              context.read<AvailabilityBloc>().add(
                                UpdateAvailability(
                                  id: widget.availableTimeId!,
                                  startTime: selectedSlot.startTime,
                                  endTime: selectedSlot.apiEndTime,
                                  isAvailable: _available,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                        } else {
                          AppConfirmationBottomSheet.show(
                            context: context,
                            title: AppLocalizations.of(
                              context,
                            ).availability_confirm_add_title,
                            description: AppLocalizations.of(
                              context,
                            ).availability_confirm_add_desc,
                            confirmLabel: AppLocalizations.of(
                              context,
                            ).availability_confirm_add_label,
                            onConfirm: () {
                              context.read<AvailabilityBloc>().add(
                                CreateAvailabilitySlots(
                                  date: _selectedDate,
                                  slots: selectedSlots
                                      .map(
                                        (slot) => AvailabilitySlotRange(
                                          startTime: slot.startTime,
                                          endTime: slot.apiEndTime,
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                        }
                        return;
                      }

                      if (_startTime == null || _endTime == null) return;

                      final now = DateTime.now();
                      final selectedStart = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _startTime!.hour,
                        _startTime!.minute,
                      );

                      final nowNormalized = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                      );

                      // Only validate "past time" if selected date is TODAY
                      final isToday =
                          _selectedDate.year == now.year &&
                          _selectedDate.month == now.month &&
                          _selectedDate.day == now.day;

                      if (isToday && selectedStart.isBefore(nowNormalized)) {
                        StatusDialog.showError(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          ).availability_invalid_time_title,
                          message: AppLocalizations.of(
                            context,
                          ).availability_past_time_error,
                        );
                        return;
                      }

                      if (_endTime!.hour < _startTime!.hour ||
                          (_endTime!.hour == _startTime!.hour &&
                              _endTime!.minute <= _startTime!.minute)) {
                        StatusDialog.showError(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          ).availability_invalid_time_title,
                          message: AppLocalizations.of(
                            context,
                          ).availability_end_before_start_error,
                        );
                        return;
                      }

                      final startTimeStr = _formatTime(_startTime);
                      final endTimeStr = _formatTime(_endTime);

                      if (isEdit) {
                        AppConfirmationBottomSheet.show(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          ).availability_confirm_edit_title,
                          description: AppLocalizations.of(
                            context,
                          ).availability_confirm_edit_desc,
                          confirmLabel: AppLocalizations.of(
                            context,
                          ).availability_save_button,
                          onConfirm: () {
                            context.read<AvailabilityBloc>().add(
                              UpdateAvailability(
                                id: widget.availableTimeId!,
                                startTime: startTimeStr,
                                endTime: endTimeStr,
                                isAvailable: _available,
                              ),
                            );
                            Navigator.pop(context);
                          },
                        );
                      } else {
                        AppConfirmationBottomSheet.show(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          ).availability_confirm_add_title,
                          description: AppLocalizations.of(
                            context,
                          ).availability_confirm_add_desc,
                          confirmLabel: AppLocalizations.of(
                            context,
                          ).availability_confirm_add_label,
                          onConfirm: () {
                            context.read<AvailabilityBloc>().add(
                              CreateAvailability(
                                date: _selectedDate,
                                startTime: startTimeStr,
                                endTime: endTimeStr,
                              ),
                            );
                            Navigator.pop(context);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
