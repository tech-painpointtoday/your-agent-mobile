import 'package:flutter/foundation.dart';
import 'package:youragent/domain/entities/property.dart';
import 'property_model.dart';

/// Helper function to parse double values from various types
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Represents improvement scores for different levels
class ImprovementScores {
  final double? currentScore;
  final double? potentialScore;
  final double? improvementPotential;

  const ImprovementScores({
    this.currentScore,
    this.potentialScore,
    this.improvementPotential,
  });

  factory ImprovementScores.fromJson(Map<String, dynamic> json) {
    return ImprovementScores(
      currentScore: _parseDouble(json['current_score']),
      potentialScore: _parseDouble(json['potential_score']),
      improvementPotential: _parseDouble(json['improvement_potential']),
    );
  }
}

/// Represents a single property result within the compatibility analysis
class PropertyCompatibilityResult {
  final Property property;
  final List<PersonCompatibilityResult> personResults;
  final double? totalScore;
  final double? averageScore;
  final double? distance;
  final Map<String, ImprovementScores>? improvementScores;

  const PropertyCompatibilityResult({
    required this.property,
    required this.personResults,
    this.totalScore,
    this.averageScore,
    this.distance,
    this.improvementScores,
  });

  /// Get the primary compatibility score (prefers total_score, falls back to average_score)
  double? get score => totalScore ?? averageScore;

  factory PropertyCompatibilityResult.fromJson(Map<String, dynamic> json) {
    // Debug logging
    if (kDebugMode) {
      debugPrint(
        '    🔍 PropertyCompatibilityResult.fromJson: Parsing property',
      );
      debugPrint('      JSON keys: ${json.keys.toList()}');
    }

    // Extract property data - must be nested under 'property' key
    final propertyData = json['property'] as Map<String, dynamic>?;
    if (propertyData == null) {
      if (kDebugMode) {
        debugPrint('      ❌ Property data is missing in compatibility result');
        debugPrint('      Available keys: ${json.keys.toList()}');
      }
      throw Exception('Property data is missing in compatibility result');
    }

    // Create a copy of property data to avoid modifying the original
    final propertyJson = Map<String, dynamic>.from(propertyData);

    // Extract compatibility score from result level and add to property data
    final totalScore = _parseDouble(json['total_score']);
    final averageScore = _parseDouble(json['average_score']);
    if (totalScore != null) {
      propertyJson['fengshui_score'] = totalScore;
      propertyJson['compatibility'] = totalScore;
    }

    // Parse the property using PropertyModel
    final property = PropertyModel.fromJson(propertyJson);

    // Parse person_results array
    final List<PersonCompatibilityResult> personResults = [];
    if (json['person_results'] != null && json['person_results'] is List) {
      final personResultsList = json['person_results'] as List<dynamic>;
      for (final item in personResultsList) {
        if (item is Map<String, dynamic>) {
          try {
            personResults.add(PersonCompatibilityResult.fromJson(item));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('      ⚠️ Error parsing person result: $e');
            }
          }
        }
      }
    }

    // Parse distance
    final distance = _parseDouble(json['distance']);

    // Parse improvement_scores
    final Map<String, ImprovementScores>? improvementScores;
    if (json['improvement_scores'] != null &&
        json['improvement_scores'] is Map) {
      final improvementScoresMap =
          json['improvement_scores'] as Map<String, dynamic>;
      improvementScores = improvementScoresMap.map(
        (key, value) => MapEntry(
          key,
          ImprovementScores.fromJson(value as Map<String, dynamic>),
        ),
      );
    } else {
      improvementScores = null;
    }

    return PropertyCompatibilityResult(
      property: property,
      personResults: personResults,
      totalScore: totalScore,
      averageScore: averageScore,
      distance: distance,
      improvementScores: improvementScores,
    );
  }
}

/// Represents person data within a compatibility result
class PersonResultData {
  final String birthday;
  final String gender;
  final String name;
  final String mobileNumber;
  final String carNumber;
  final int weight;

  const PersonResultData({
    required this.birthday,
    required this.gender,
    required this.name,
    required this.mobileNumber,
    required this.carNumber,
    required this.weight,
  });

  factory PersonResultData.fromJson(Map<String, dynamic> json) {
    return PersonResultData(
      birthday: json['birthday'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String? ?? '',
      carNumber: json['car_number'] as String? ?? '',
      weight: json['weight'] as int? ?? 0,
    );
  }
}

/// Represents compatibility result for a specific person
class PersonCompatibilityResult {
  final int personIndex;
  final PersonResultData personData;
  final Map<String, dynamic> comprehensiveResult;
  final double? weightedScore;
  final Map<String, dynamic>? improvementSummaries;

  const PersonCompatibilityResult({
    required this.personIndex,
    required this.personData,
    required this.comprehensiveResult,
    this.weightedScore,
    this.improvementSummaries,
  });

  /// Get the primary score (weighted_score or from comprehensive_result)
  double? get score {
    if (weightedScore != null) return weightedScore;
    final avgScore = comprehensiveResult['average_score'];
    return _parseDouble(avgScore);
  }

  factory PersonCompatibilityResult.fromJson(Map<String, dynamic> json) {
    // Parse person_index
    final personIndex = json['person_index'] as int? ?? 0;

    // Parse person_data
    final personDataJson = json['person_data'] as Map<String, dynamic>?;
    if (personDataJson == null) {
      throw Exception('person_data is missing in person compatibility result');
    }
    final personData = PersonResultData.fromJson(personDataJson);

    // Parse comprehensive_result (keep as raw map for now, can be expanded later)
    final comprehensiveResult =
        json['comprehensive_result'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    // Parse weighted_score
    final weightedScore = _parseDouble(json['weighted_score']);

    // Parse improvement_summaries
    final Map<String, dynamic>? improvementSummaries =
        json['improvement_summaries'] as Map<String, dynamic>?;

    return PersonCompatibilityResult(
      personIndex: personIndex,
      personData: personData,
      comprehensiveResult: comprehensiveResult,
      weightedScore: weightedScore,
      improvementSummaries: improvementSummaries,
    );
  }
}

/// Represents a person in the compatibility analysis
class PersonData {
  final String name;
  final String? birthday;
  final String? gender;
  final String? mobileNumber;
  final String? carNumber;
  final int? weight;

  const PersonData({
    required this.name,
    this.birthday,
    this.gender,
    this.mobileNumber,
    this.carNumber,
    this.weight,
  });

  factory PersonData.fromJson(Map<String, dynamic> json) {
    return PersonData(
      name: json['name'] as String? ?? '',
      birthday: json['birthday'] as String?,
      gender: json['gender'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      carNumber: json['car_number'] as String?,
      weight: json['weight'] as int?,
    );
  }
}

/// Main compatibility analysis result matching the actual API response structure
class CompatibilityResult {
  final List<PersonData> people;
  final String location;
  final double? budgetMin;
  final double? budgetMax;
  final List<PropertyCompatibilityResult> scoredProperties;
  final List<dynamic>? compatibilityWeights;
  final int? totalProperties;
  final Map<String, dynamic> raw;

  const CompatibilityResult({
    required this.people,
    required this.location,
    this.budgetMin,
    this.budgetMax,
    required this.scoredProperties,
    this.compatibilityWeights,
    this.totalProperties,
    required this.raw,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    // Debug logging
    if (kDebugMode) {
      debugPrint('🔍 CompatibilityResult.fromJson: Parsing response');
      debugPrint('  JSON keys: ${json.keys.toList()}');
    }

    // Parse people array
    final List<PersonData> people = [];
    if (json['people'] != null && json['people'] is List) {
      final peopleList = json['people'] as List<dynamic>;
      for (final personJson in peopleList) {
        if (personJson is Map<String, dynamic>) {
          try {
            people.add(PersonData.fromJson(personJson));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('  ⚠️ Error parsing person: $e');
            }
          }
        }
      }
    }

    // Parse location
    final String location = json['location'] as String? ?? '';

    // Parse budget
    final double? budgetMin = _parseDouble(json['budgetMin']);
    final double? budgetMax = _parseDouble(json['budgetMax']);

    // Parse scoredProperties array
    final List<PropertyCompatibilityResult> scoredProperties = [];
    if (json['scoredProperties'] != null && json['scoredProperties'] is List) {
      final scoredPropertiesList = json['scoredProperties'] as List<dynamic>;
      if (kDebugMode) {
        debugPrint('  scoredProperties length: ${scoredPropertiesList.length}');
      }
      for (int i = 0; i < scoredPropertiesList.length; i++) {
        final item = scoredPropertiesList[i];
        if (item is! Map<String, dynamic>) {
          if (kDebugMode) {
            debugPrint('  ⚠️ Scored property item $i is not a Map, skipping');
          }
          continue;
        }
        try {
          // The item might be a property with score, or have nested structure
          // Try to parse it as PropertyCompatibilityResult
          scoredProperties.add(PropertyCompatibilityResult.fromJson(item));
          if (kDebugMode) {
            debugPrint('  ✅ Successfully parsed scored property $i');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('  ❌ Error parsing scored property $i: $e');
            debugPrint('  Stack trace: $stackTrace');
            debugPrint('  Item keys: ${item.keys.toList()}');
          }
          continue;
        }
      }
    }

    // Parse compatibilityWeights - can be an array or null
    final List<dynamic>? compatibilityWeights =
        json['compatibilityWeights'] as List<dynamic>?;

    // Parse total_properties
    final int? totalProperties = json['total_properties'] as int?;

    if (kDebugMode) {
      debugPrint(
        '  📊 Final scoredProperties count: ${scoredProperties.length}',
      );
      debugPrint('  Total properties: $totalProperties');
    }

    return CompatibilityResult(
      people: people,
      location: location,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      scoredProperties: scoredProperties,
      compatibilityWeights: compatibilityWeights,
      totalProperties: totalProperties,
      raw: json,
    );
  }

  /// Get all properties from the scored properties
  List<Property> get properties =>
      scoredProperties.map((r) => r.property).toList();

  /// Alias for properties (for easier access)
  List<Property> get propertyList => properties;

  /// Alias for scoredProperties (for backward compatibility)
  List<PropertyCompatibilityResult> get results => scoredProperties;

  /// Get compatibility score for a specific property ID
  double? getScoreForProperty(int propertyId) {
    try {
      return scoredProperties
          .firstWhere((r) => r.property.id == propertyId)
          .score;
    } catch (e) {
      return null;
    }
  }

  /// Get property compatibility result for a specific property ID
  PropertyCompatibilityResult? getResultForProperty(int propertyId) {
    try {
      return scoredProperties.firstWhere((r) => r.property.id == propertyId);
    } catch (e) {
      return null;
    }
  }
}
