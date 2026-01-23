import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/member.dart';

class SearchFormState extends Equatable {
  final List<Member> members;
  final String location;
  final String budgetMin;
  final String budgetMax;
  final String? propertyType;

  /// 0–100, used by the meter
  final double formCompleteness;

  /// Whether the form is valid enough to submit
  final bool isFormValid;

  const SearchFormState({
    required this.members,
    required this.location,
    required this.budgetMin,
    required this.budgetMax,
    required this.propertyType,
    required this.formCompleteness,
    required this.isFormValid,
  });

  factory SearchFormState.initial(List<Member> initialMembers) {
    return SearchFormState(
      members: List<Member>.from(initialMembers),
      location: '',
      budgetMin: '',
      budgetMax: '',
      propertyType: null,
      formCompleteness: 0,
      isFormValid: false,
    );
  }

  SearchFormState copyWith({
    List<Member>? members,
    String? location,
    String? budgetMin,
    String? budgetMax,
    String? propertyType,
    double? formCompleteness,
    bool? isFormValid,
  }) {
    return SearchFormState(
      members: members ?? this.members,
      location: location ?? this.location,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      propertyType: propertyType ?? this.propertyType,
      formCompleteness: formCompleteness ?? this.formCompleteness,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [members, location, budgetMin, budgetMax, propertyType, formCompleteness, isFormValid];
}
