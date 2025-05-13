class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String token;
  final String address;
  final String lat;
  final String lng;
  final int city_id;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.token,
    required this.address,
    required this.lat,
    required this.lng,
    required this.city_id,
  });

  /// Create a modified copy of this UserModel
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? token,
    String? address,
    String? lat,
    String? lng,
    int? city_id,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      token: token ?? this.token,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      city_id: city_id ?? this.city_id,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic raw) {
      if (raw is int) return raw;
      if (raw is String) return int.tryParse(raw) ?? 0;
      return 0;
    }

    return UserModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
      city_id: _parseInt(json['city_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'token': token,
    'address': address,
    'lat': lat,
    'lng': lng,
    'city_id': city_id,
  };
}
