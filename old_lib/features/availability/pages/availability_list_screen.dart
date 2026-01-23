import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/app_layout.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Availability List Screen - shows available times with filter functionality
class AvailabilityListScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final UserRole? role;

  const AvailabilityListScreen({
    super.key,
    required this.changeLocale,
    this.role,
  });

  @override
  State<AvailabilityListScreen> createState() => _AvailabilityListScreenState();
}

class _AvailabilityListScreenState extends State<AvailabilityListScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'all';
  List<Map<String, dynamic>> _allTimes = [];
  List<Map<String, dynamic>> _filteredTimes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableTimes();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableTimes() async {
    setState(() => _isLoading = true);
    try {
      final times = await DependencyInjection.availabilityApiService
          .listAvailableTimes();
      setState(() {
        _allTimes = times;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback to empty list or handle error silently/toast
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTimes = _allTimes.where((time) {
        // Filter by status
        if (_selectedStatus != 'all') {
          final isAvailable = time['is_available'] as bool? ?? true;
          if (_selectedStatus == 'available' && !isAvailable) return false;
          if (_selectedStatus == 'unavailable' && isAvailable) return false;
        }

        // Filter by date range
        if (_startDate != null || _endDate != null) {
          try {
            final dateStr = time['date'] as String;
            final date = DateTime.parse(dateStr);

            if (_startDate != null && date.isBefore(_startDate!)) return false;
            if (_endDate != null && date.isAfter(_endDate!)) return false;
          } catch (_) {
            return true;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    Map<String, dynamic> time,
    AppLocalizations l10n,
  ) async {
    final confirmed = await StatusDialog.showDestructive(
      context: context,
      title: l10n.delete_time_slot,
      message: l10n.delete_time_slot_confirm,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
    );

    if (confirmed == true && context.mounted) {
      // Optimistic update
      final id = time['id'];
      final originalTimes = List<Map<String, dynamic>>.from(_allTimes);

      setState(() {
        _allTimes.removeWhere((t) => t['id'] == id);
        _applyFilters();
      });

      try {
        await DependencyInjection.availabilityApiService.deleteAvailableTime(
          id,
        );
        if (context.mounted) {
          StatusDialog.showSuccess(
            context: context,
            title: l10n.success,
            message: l10n.time_slot_deleted,
          );
        }
      } catch (e) {
        // Revert on error
        if (context.mounted) {
          setState(() {
            _allTimes = originalTimes;
            _applyFilters();
          });
          StatusDialog.showError(
            context: context,
            title: l10n.error,
            message: '${l10n.error_deleting}: $e',
          );
        }
      }
    }
  }

  String _getBasePath() {
    return widget.role == UserRole.agent
        ? '/agent/availability'
        : '/availability';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AppLayout(
      changeLocale: widget.changeLocale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeaderSection(context, l10n, isDesktop),
          const SizedBox(height: 24),
          // Filter section
          _buildFilterSection(context, l10n, isDesktop),
          const SizedBox(height: 24),
          // Content section
          _isLoading
              ? const AppLoader()
              : _buildContentSection(context, l10n, isDesktop),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return isDesktop
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.available_times_title,
                    style: GoogleFonts.anuphan(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eerieBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.available_times_subtitle,
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      color: AppColors.shadyLady,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push('${_getBasePath()}/calendar'),
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(l10n.calendar_view),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('${_getBasePath()}/create'),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.add_time_slot),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.available_times_title,
                style: GoogleFonts.anuphan(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eerieBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.available_times_subtitle,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.shadyLady,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('${_getBasePath()}/calendar'),
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: Text(
                        l10n.calendar_view,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('${_getBasePath()}/create'),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        l10n.add_time_slot,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildFilterSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _buildDateField(context, l10n, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildDateField(context, l10n, false)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusDropdown(context, l10n)),
                const SizedBox(width: 16),
                _buildFilterButton(context, l10n),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDateField(context, l10n, true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDateField(context, l10n, false)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatusDropdown(context, l10n)),
                    const SizedBox(width: 12),
                    _buildFilterButton(context, l10n),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    AppLocalizations l10n,
    bool isStartDate,
  ) {
    return TextField(
      controller: isStartDate ? _startDateController : _endDateController,
      readOnly: true,
      onTap: () => _selectDate(context, isStartDate),
      style: GoogleFonts.anuphan(),
      decoration: InputDecoration(
        hintText: isStartDate ? l10n.start_date : l10n.end_date,
        hintStyle: GoogleFonts.anuphan(color: AppColors.shadyLady),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      decoration: InputDecoration(
        labelText: l10n.status,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: [
        DropdownMenuItem(value: 'all', child: Text(l10n.all)),
        DropdownMenuItem(
          value: 'available',
          child: Text(l10n.status_available),
        ),
        DropdownMenuItem(
          value: 'unavailable',
          child: Text(l10n.status_unavailable),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }

  Widget _buildFilterButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: _applyFilters,
      icon: const Icon(Icons.filter_alt_outlined, size: 18),
      label: Text(l10n.filter),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: _filteredTimes.isEmpty
          ? _buildEmptyState(context, l10n)
          : Column(
              children: _filteredTimes
                  .map((time) => _buildTimeCard(context, l10n, time))
                  .toList(),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: AppColors.shadyLady,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.no_available_times,
              style: GoogleFonts.anuphan(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.no_available_times_hint,
              style: GoogleFonts.anuphan(color: AppColors.shadyLady),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('${_getBasePath()}/create'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.add_time_slot),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> time,
  ) {
    final isAvailable = time['is_available'] as bool? ?? true;
    final date = time['date'] as String;
    final startTime = time['start_time'] as String;
    final endTime = time['end_time'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.wildSand,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.shadyLady,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$startTime - $endTime',
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.shadyLady,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.emerald500.withValues(alpha: 0.1)
                  : AppColors.ruby500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAvailable ? l10n.status_available : l10n.status_unavailable,
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAvailable ? AppColors.emerald500 : AppColors.ruby500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () =>
                context.push('${_getBasePath()}/${time['id']}/edit'),
            icon: const Icon(Icons.edit_outlined, color: AppColors.shadyLady),
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(context, time, l10n),
            icon: const Icon(Icons.delete_outline, color: AppColors.shadyLady),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
