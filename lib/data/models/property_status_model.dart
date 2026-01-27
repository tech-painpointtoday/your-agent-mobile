class PropertyStatusModel {
  final int? completionPercentage;
  final String? nextStep;
  final String? status;
  final bool? isPublished;
  final Map<String, dynamic>? completionStatus;

  PropertyStatusModel({
    this.completionPercentage,
    this.nextStep,
    this.status,
    this.isPublished,
    this.completionStatus,
  });

  factory PropertyStatusModel.fromJson(Map<String, dynamic> json) {
    return PropertyStatusModel(
      completionPercentage: json['completion_percentage'] as int?,
      nextStep: json['next_step'] as String?,
      status: json['status'] as String?,
      isPublished: json['is_published'] as bool?,
      completionStatus: json['completion_status'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completion_percentage': completionPercentage,
      'next_step': nextStep,
      'status': status,
      'is_published': isPublished,
      'completion_status': completionStatus,
    };
  }
}
