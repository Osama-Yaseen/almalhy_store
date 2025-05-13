class CategoryModel {
  final int id;
  final int? parentId;
  final String nameAr;
  final String nameEn;
  final bool active;
  final int level;
  final String? logo;
  final bool isFinalLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    this.parentId,
    required this.nameAr,
    required this.nameEn,
    required this.active,
    required this.level,
    this.logo,
    required this.isFinalLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      parentId: json['parent_id'] != null ? (json['parent_id'] as int) : null,
      nameAr: json['name'] as String? ?? '',
      nameEn: json['name_translations'] as String? ?? '',
      active: (json['active'] as int? ?? 0) == 1,
      level: json['level'] as int? ?? 0,
      logo: json['logo'] as String?,
      isFinalLevel: (json['is_final_level'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'parent_id': parentId,
    'name': nameAr,
    'name_translations': nameEn,
    'active': active ? 1 : 0,
    'level': level,
    'logo': logo,
    'is_final_level': isFinalLevel ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
