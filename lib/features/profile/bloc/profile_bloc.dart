import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/agent_profile.dart';
import '../../../services/auth_api_service.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfilePhoto extends ProfileEvent {
  final String filePath;
  const UpdateProfilePhoto(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UpdateWorkInfo extends ProfileEvent {
  final Map<String, dynamic> data;
  const UpdateWorkInfo(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateServiceArea extends ProfileEvent {
  final Map<String, dynamic> data;
  const UpdateServiceArea(this.data);

  @override
  List<Object?> get props => [data];
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AgentProfile profile;
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

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthApiService _authApiService;

  ProfileBloc(this._authApiService) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateWorkInfo>(_onUpdateWorkInfo);
    on<UpdateServiceArea>(_onUpdateServiceArea);
    on<ChangePassword>(_onChangePassword);
    on<UpdateProfilePhoto>(_onUpdateProfilePhoto);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final json = await _authApiService.getAgentProfile();
      if (json['success'] == true && json['data'] != null) {
        final profile = AgentProfile.fromJson(json['data']);
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Failed to load profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateWorkInfo(
    UpdateWorkInfo event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    try {
      final json = await _authApiService.updateAgentProfile(event.data);
      if (json['success'] == true) {
        emit(ProfileUpdateSuccess());
        // Profile screen will refetch when user navigates back (didPopNext).
      } else {
        emit(ProfileError(json['message'] ?? 'Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateServiceArea(
    UpdateServiceArea event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    try {
      final json = await _authApiService.updateAgentProfile(event.data);
      if (json['success'] == true) {
        emit(ProfileUpdateSuccess());
        // Profile screen will refetch when user navigates back (didPopNext).
      } else {
        emit(ProfileError(json['message'] ?? 'Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    try {
      final json = await _authApiService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      if (json['success'] == true) {
        emit(ProfileUpdateSuccess());
      } else {
        emit(ProfileError(json['message'] ?? 'Failed to change password'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    try {
      final file = File(event.filePath);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 2) {
        emit(const ProfileError('Image size must be less than 2MB'));
        return;
      }

      final json = await _authApiService.updateProfilePhoto(event.filePath);
      if (json['success'] == true) {
        emit(ProfileUpdateSuccess());
        add(FetchProfile());
      } else {
        emit(ProfileError(json['message'] ?? 'Failed to update profile photo'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
