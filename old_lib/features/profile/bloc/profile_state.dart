part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  final UserProfileModel profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserProfileModel profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateError extends ProfileState {
  final String message;
  final UserProfileModel? previousProfile;

  const ProfileUpdateError(this.message, {this.previousProfile});

  @override
  List<Object?> get props => [message, previousProfile];
}

class ProfileVerificationSent extends ProfileState {
  final UserProfileModel profile;

  const ProfileVerificationSent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileVerificationError extends ProfileState {
  final String message;
  final UserProfileModel? previousProfile;

  const ProfileVerificationError(this.message, {this.previousProfile});

  @override
  List<Object?> get props => [message, previousProfile];
}
