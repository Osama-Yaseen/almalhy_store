class BrandModel {
  final String id;
  final String name;
  final String logo;

  BrandModel({required this.id, required this.name, required this.logo});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'].toString(),
      name: json['name'],
      logo: json['logo'],
    );
  }
}
