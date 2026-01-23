import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/data/models/user_profile_model.dart';
import 'package:youragent/services/user_profile_storage_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileResendVerificationRequested>(_onResendVerificationRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Call both APIs in parallel for better performance
      final authApiService = DependencyInjection.authApiService;
      final agentApiService = DependencyInjection.agentApiService;
      
      // 1. GET /user - for header update and save to SharedPreferences
      final userDataFuture = authApiService.getCurrentUser();
      
      // 2. GET /agent/profile - for full profile data with verification status
      final profileDataFuture = agentApiService.getProfile();
      
      // Wait for both to complete
      final userData = await userDataFuture;
      final profile = await profileDataFuture;
      
      // Save user data to SharedPreferences for header
      final userProfile = UserProfileModel.fromJson(userData);
      await UserProfileStorageService().saveProfile(userProfile);
      
      // Use full profile data from GET /agent/profile for the screen
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    UserProfileModel? previousProfile;

    if (currentState is ProfileLoaded) {
      previousProfile = currentState.profile;
      emit(ProfileUpdating(previousProfile));
    } else if (currentState is ProfileUpdateSuccess) {
      previousProfile = currentState.profile;
      emit(ProfileUpdating(previousProfile));
    }

    try {
      await DependencyInjection.agentApiService.updateProfile(
        data: event.profileData,
      );
      // Reload profile to get updated data
      final updatedProfile =
          await DependencyInjection.agentApiService.getProfile();
      emit(ProfileUpdateSuccess(updatedProfile));
    } catch (e) {
      emit(ProfileUpdateError(
        e.toString(),
        previousProfile: previousProfile,
      ));
    }
  }

  Future<void> _onResendVerificationRequested(
    ProfileResendVerificationRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    UserProfileModel? previousProfile;

    if (currentState is ProfileLoaded) {
      previousProfile = currentState.profile;
    } else if (currentState is ProfileUpdateSuccess) {
      previousProfile = currentState.profile;
    }

    try {
      await DependencyInjection.agentApiService.resendVerification();
      // Reload profile to get updated verification status
      final updatedProfile =
          await DependencyInjection.agentApiService.getProfile();
      emit(ProfileVerificationSent(updatedProfile));
    } catch (e) {
      emit(ProfileVerificationError(
        e.toString(),
        previousProfile: previousProfile,
      ));
    }
  }
}
