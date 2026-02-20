import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_dropdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/calendar/bloc/availability/availability_bloc.dart';
import 'package:youragent/features/calendar/bloc/availability/availability_event.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

enum AvailabilityMode { add, edit }

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

    _dateCtrl = TextEditingController(
      text: _dateFormatter.format(_selectedDate),
    );
    _startCtrl = TextEditingController(text: _formatTime(_startTime));
    _endCtrl = TextEditingController(text: _formatTime(_endTime));
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

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.mode == AvailabilityMode.edit;

    return Container(
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
            isEdit ? 'แก้ไขช่วงเวลาว่าง' : 'เพิ่มช่วงเวลาว่าง',
            style: GoogleFonts.anuphan(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'กรุณาตรวจสอบตารางเวลาของคุณก่อน เพื่อป้องกันการเพิ่มช่วงเวลาที่ซ้อนกันในวันเดียวกัน',
            style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.baseGrey),
          ),
          const SizedBox(height: 32),

          // Date field
          AppTextField(
            label: 'วันที่',
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

          // Time fields
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'เวลาเริ่มต้น',
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
                  label: 'เวลาสิ้นสุด',
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

          // Status field (only in Edit mode according to image, or always if useful)
          // The image shows "สถานะ" for edit.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'สถานะ',
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
                itemLabel: (val) =>
                    val ? 'พร้อมให้บริการ' : 'ไม่พร้อมให้บริการ',
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _available = val);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'ยกเลิก',
                  style: AppButtonStyle.outline,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: isEdit ? 'บันทึก' : 'เพิ่มเลย',
                  style: AppButtonStyle.primary,
                  onPressed: () {
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
                        title: 'เวลาไม่ถูกต้อง',
                        message: 'ไม่สามารถเลือกเวลาในอดีตได้',
                      );
                      return;
                    }

                    if (_endTime!.hour < _startTime!.hour ||
                        (_endTime!.hour == _startTime!.hour &&
                            _endTime!.minute <= _startTime!.minute)) {
                      StatusDialog.showError(
                        context: context,
                        title: 'เวลาไม่ถูกต้อง',
                        message: 'เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มต้น',
                      );
                      return;
                    }

                    final startTimeStr = _formatTime(_startTime);
                    final endTimeStr = _formatTime(_endTime);

                    if (isEdit) {
                      StatusDialog.confirm(
                        context: context,
                        title: 'ยืนยันการแก้ไข?',
                        message: 'คุณต้องการบันทึกการเปลี่ยนแปลงใช่หรือไม่?',
                        confirmLabel: 'บันทึก',
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
                      context.read<AvailabilityBloc>().add(
                        CreateAvailability(
                          date: _selectedDate,
                          startTime: startTimeStr,
                          endTime: endTimeStr,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
