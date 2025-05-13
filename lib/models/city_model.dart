class CityModel {
  final int id;
  final String nameAr;
  final String nameEn;

  CityModel({required this.id, required this.nameAr, required this.nameEn});

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String,
    nameEn: json['name_en'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_ar': nameAr,
    'name_en': nameEn,
  };

  String localizedName(String lang) =>
      lang.toLowerCase() == 'ar' ? nameAr : nameEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
