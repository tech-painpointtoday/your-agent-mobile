import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/domain/entities/member.dart';

import 'search_form_state.dart';

class SearchFormCubit extends Cubit<SearchFormState> {
  SearchFormCubit(List<Member> initialMembers) : super(SearchFormState.initial(initialMembers)) {
    _recalculate();
  }

  /// Sync full form from current controllers / members.
  /// This lets the UI remain controller-driven while the cubit
  /// is the single source of truth for derived values like completeness.
  void syncForm({
    required List<Member> members,
    required String location,
    required String budgetMin,
    required String budgetMax,
    required String? propertyType,
  }) {
    emit(
      state.copyWith(
        members: List<Member>.from(members),
        location: location,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        propertyType: propertyType,
      ),
    );
    _recalculate();
  }

  /// Recalculate completeness and validity from current state.
  void _recalculate() {
    final completeness = _computeFormCompleteness(
      members: state.members,
      location: state.location,
      budgetMin: state.budgetMin,
      budgetMax: state.budgetMax,
      propertyType: state.propertyType,
    );

    final valid = _computeIsFormValid(members: state.members, location: state.location);

    emit(state.copyWith(formCompleteness: completeness, isFormValid: valid));
  }

  double _computeFormCompleteness({
    required List<Member> members,
    required String location,
    required String budgetMin,
    required String budgetMax,
    required String? propertyType,
  }) {
    double completeness = 0;

    // Property fields: 4 fields, 50% weight total (12.5 each)
    if (location.trim().isNotEmpty) completeness += 12.5;
    if (budgetMin.trim().isNotEmpty) completeness += 12.5;
    if (budgetMax.trim().isNotEmpty) completeness += 12.5;
    if (propertyType != null) completeness += 12.5;

    // Members: up to 5 members, 10% each (name/dob/gender)
    for (final member in members) {
      final hasName = member.name.trim().isNotEmpty;
      final hasDob = member.dob != null;
      final hasGender = member.gender != null && member.gender!.trim().isNotEmpty;

      if (hasName && hasDob && hasGender) {
        completeness += 10;
      } else {
        int filled = 0;
        if (hasName) filled++;
        if (hasDob) filled++;
        if (hasGender) filled++;
        completeness += (filled / 3) * 10;
      }
    }

    return completeness.clamp(0.0, 100.0);
  }

  bool _computeIsFormValid({required List<Member> members, required String location}) {
    if (location.trim().isEmpty) return false;

    if (members.isEmpty) return false;

    for (final m in members) {
      if (m.name.trim().isEmpty) return false;
      if (m.dob == null) return false;
      if (m.gender == null || m.gender!.trim().isEmpty) return false;
    }

    // Weight total must be exactly 100
    final totalWeight = members.fold<int>(0, (sum, m) => sum + (m.weight));
    if (totalWeight != 100) return false;

    return true;
  }
}
