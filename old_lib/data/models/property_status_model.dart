import 'package:equatable/equatable.dart';

/// Property Status Model - represents the completion status of a property
class PropertyStatusModel extends Equatable {
  final PropertyCompletionStatus? completionStatus;
  final int completionPercentage;
  final String? nextStep;

  const PropertyStatusModel({
    this.completionStatus,
    required this.completionPercentage,
    this.nextStep,
  });

  factory PropertyStatusModel.fromJson(Map<String, dynamic> json) {
    return PropertyStatusModel(
      completionStatus: json['completion_status'] != null
          ? PropertyCompletionStatus.fromJson(
              json['completion_status'] as Map<String, dynamic>,
            )
          : null,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
      nextStep: json['next_step'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completion_status': completionStatus?.toJson(),
      'completion_percentage': completionPercentage,
      'next_step': nextStep,
    };
  }

  @override
  List<Object?> get props => [completionStatus, completionPercentage, nextStep];
}

/// Property Completion Status - tracks completion of each step
class PropertyCompletionStatus extends Equatable {
  final PhotoCompletionStatus? photos;
  final StepCompletionStatus? specifications;
  final StepCompletionStatus? location;

  const PropertyCompletionStatus({
    this.photos,
    this.specifications,
    this.location,
  });

  factory PropertyCompletionStatus.fromJson(Map<String, dynamic> json) {
    return PropertyCompletionStatus(
      photos: json['photos'] != null
          ? PhotoCompletionStatus.fromJson(
              json['photos'] as Map<String, dynamic>,
            )
          : null,
      specifications: json['specifications'] != null
          ? StepCompletionStatus.fromJson(
              json['specifications'] as Map<String, dynamic>,
            )
          : null,
      location: json['location'] != null
          ? StepCompletionStatus.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photos': photos?.toJson(),
      'specifications': specifications?.toJson(),
      'location': location?.toJson(),
    };
  }

  @override
  List<Object?> get props => [photos, specifications, location];
}

/// Photo Completion Status - tracks photo upload completion
class PhotoCompletionStatus extends Equatable {
  final bool completed;
  final int count;
  final int validCount;
  final int expiredCount;
  final int s3Count;
  final int s3NeedingRefresh;
  final int externalCount;
  final int step;

  const PhotoCompletionStatus({
    required this.completed,
    required this.count,
    required this.validCount,
    required this.expiredCount,
    required this.s3Count,
    required this.s3NeedingRefresh,
    required this.externalCount,
    required this.step,
  });

  factory PhotoCompletionStatus.fromJson(Map<String, dynamic> json) {
    return PhotoCompletionStatus(
      completed: json['completed'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      validCount: json['valid_count'] as int? ?? 0,
      expiredCount: json['expired_count'] as int? ?? 0,
      s3Count: json['s3_count'] as int? ?? 0,
      s3NeedingRefresh: json['s3_needing_refresh'] as int? ?? 0,
      externalCount: json['external_count'] as int? ?? 0,
      step: json['step'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'count': count,
      'valid_count': validCount,
      'expired_count': expiredCount,
      's3_count': s3Count,
      's3_needing_refresh': s3NeedingRefresh,
      'external_count': externalCount,
      'step': step,
    };
  }

  @override
  List<Object?> get props => [
        completed,
        count,
        validCount,
        expiredCount,
        s3Count,
        s3NeedingRefresh,
        externalCount,
        step,
      ];
}

/// Step Completion Status - tracks completion of a workflow step
class StepCompletionStatus extends Equatable {
  final bool completed;
  final int step;

  const StepCompletionStatus({
    required this.completed,
    required this.step,
  });

  factory StepCompletionStatus.fromJson(Map<String, dynamic> json) {
    return StepCompletionStatus(
      completed: json['completed'] as bool? ?? false,
      step: json['step'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'step': step,
    };
  }

  @override
  List<Object?> get props => [completed, step];
}



