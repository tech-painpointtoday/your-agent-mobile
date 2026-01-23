import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String name;
  final DateTime? dob;
  final String? gender;
  final int weight;

  const Member({this.name = '', this.dob, this.gender, this.weight = 50});

  Member copyWith({String? name, DateTime? dob, String? gender, int? weight}) {
    return Member(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
    );
  }

  @override
  List<Object?> get props => [name, dob, gender, weight];
}
