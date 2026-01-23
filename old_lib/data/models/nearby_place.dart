class NearbyPlace {
  final String name;
  final String? address;
  final double distanceMeters;
  final double? rating;
  final int? userRatingsTotal;

  const NearbyPlace({
    required this.name,
    required this.distanceMeters,
    this.address,
    this.rating,
    this.userRatingsTotal,
  });

  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} กม.';
    }
    return '${distanceMeters.toStringAsFixed(0)} ม.';
  }
}

