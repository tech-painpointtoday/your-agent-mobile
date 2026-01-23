import 'package:equatable/equatable.dart';

/// Developer model for master data
class Developer extends Equatable {
  final int id;
  final String nameTh;
  final String nameEn;
  final String slug;

  const Developer({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.slug,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['id'] as int,
      nameTh: json['name_th'] as String? ?? json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name_th': nameTh, 'name_en': nameEn, 'slug': slug};
  }

  @override
  List<Object?> get props => [id, nameTh, nameEn, slug];
}
