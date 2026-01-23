import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/widgets/app_layout.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/services/api_response_service.dart';

import 'package:youragent/core/errors/validation_exception.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

/// Availability Edit Screen - edit available time
class AvailabilityEditScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final int availabilityId;

  const AvailabilityEditScreen({
    super.key,
    required this.changeLocale,
    required this.availabilityId,
  });

  @override
  State<AvailabilityEditScreen> createState() => _AvailabilityEditScreenState();
}

class _AvailabilityEditScreenState extends State<AvailabilityEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadAvailabilityData();
  }

  Future<void> _loadAvailabilityData() async {
    setState(() => _isLoading = true);
    try {
      final times = await DependencyInjection.availabilityApiService
          .listAvailableTimes();
      final existingTime = times.firstWhere(
        (time) => time['id'] == widget.availabilityId,
        orElse: () => <String, dynamic>{},
      );

      if (existingTime.isNotEmpty) {
        final dateStr = existingTime['date'] as String;
        final startTimeStr = existingTime['start_time'] as String;
        final endTimeStr = existingTime['end_time'] as String;

        try {
          if (dateStr.contains(' ')) {
            _selectedDate = DateFormat('dd MM yyyy').parse(dateStr);
          } else {
            _selectedDate = DateTime.parse(dateStr);
          }
          _dateController.text = DateFormat(
            'dd MM yyyy',
          ).format(_selectedDate!);
        } catch (_) {
          _dateController.text = dateStr;
        }

        final startParts = startTimeStr.split(':');
        if (startParts.length == 2) {
          _startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );
          _startTimeController.text = startTimeStr;
        }

        final endParts = endTimeStr.split(':');
        if (endParts.length == 2) {
          _endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
          _endTimeController.text = endTimeStr;
        }

        _isAvailable = existingTime['is_available'] as bool? ?? true;
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                dayPeriodBorderSide: BorderSide.none,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        } else {
          _endTime = picked;
          _endTimeController.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes <= startMinutes) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.end_time_must_be_after_start_time)),
          );
        }
        return;
      }
    }

    if (_selectedDate != null && _endTime != null) {
      final now = DateTime.now();
      final isToday =
          _selectedDate!.year == now.year &&
          _selectedDate!.month == now.month &&
          _selectedDate!.day == now.day;
      if (isToday) {
        final endDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _endTime!.hour,
          _endTime!.minute,
        );
        if (endDateTime.isBefore(now)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time range must end in the future'),
              ),
            );
          }
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await DependencyInjection.availabilityApiService.updateAvailableTime(
        availabilityId: widget.availabilityId,
        date: _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : _dateController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        isAvailable: _isAvailable,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.property_updated_success)));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String errorMessage;

        if (e is ValidationException) {
          errorMessage = e.message;
        } else {
          errorMessage = ApiResponseService.getErrorMessage(e);
        }

        StatusDialog.showError(
          context: context,
          title: l10n.error_creating_availability,
          message: errorMessage,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AppLayout(
      changeLocale: widget.changeLocale,
      child: _isLoading
          ? const AppLoader()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(l10n.back_to_availability),
                      ),
                      const SizedBox(height: 16),
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.bonJour,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.edit_property,
                              style: GoogleFonts.anuphan(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.eerieBlack,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Date field
                            _buildFormField(
                              label: '${l10n.date} *',
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: InputDecoration(
                                  hintText: 'DD MM YYYY',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? l10n.this_field_required
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Time fields
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: _buildTimeField(
                                          context,
                                          l10n,
                                          true,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTimeField(
                                          context,
                                          l10n,
                                          false,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildTimeField(context, l10n, true),
                                      const SizedBox(height: 16),
                                      _buildTimeField(context, l10n, false),
                                    ],
                                  ),
                            const SizedBox(height: 16),
                            // Status toggle
                            _buildStatusToggle(context, l10n),
                            const SizedBox(height: 24),
                            // Action buttons
                            _buildActionButtons(context, l10n, isDesktop),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    AppLocalizations l10n,
    bool isStartTime,
  ) {
    return _buildFormField(
      label: '${isStartTime ? l10n.start_time : l10n.end_time} *',
      child: TextFormField(
        controller: isStartTime ? _startTimeController : _endTimeController,
        readOnly: true,
        onTap: () => _selectTime(context, isStartTime),
        decoration: InputDecoration(
          hintText: isStartTime ? '09:00' : '17:00',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.access_time),
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? l10n.this_field_required : null,
      ),
    );
  }

  Widget _buildStatusToggle(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.status,
          style: GoogleFonts.anuphan(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption(
                context,
                l10n.status_available,
                true,
                AppColors.emerald500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusOption(
                context,
                l10n.status_unavailable,
                false,
                AppColors.ruby500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String label,
    bool isAvailableOption,
    Color color,
  ) {
    final isSelected = _isAvailable == isAvailableOption;

    return GestureDetector(
      onTap: () => setState(() => _isAvailable = isAvailableOption),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.wildSand,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.bonJour,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : AppColors.shadyLady,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.shadyLady,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return isDesktop
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.save),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => context.pop(),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          );
  }
}
