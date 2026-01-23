part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const ProfileUpdateRequested(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class ProfileResendVerificationRequested extends ProfileEvent {
  const ProfileResendVerificationRequested();
}
