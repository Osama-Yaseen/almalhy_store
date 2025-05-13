class ProductModel {
  final int id;
  final String? sku;
  final String? barcode;
  final int brandId;
  final int categoryId;
  final String name;
  final String? picture;
  final String? image;
  final DateTime? expiryDate;
  final bool active;
  final int quantity;
  final double price;
  final double? salePrice;
  final int promotion;
  final int minimumQuantity;
  final int? maximumQuantity;
  final int? inventoryId;
  final int? supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFinalLevel;
  // nested category info if needed
  // final CategoryModel? category;

  ProductModel({
    required this.id,
    this.sku,
    this.barcode,
    required this.brandId,
    required this.categoryId,
    required this.name,
    this.picture,
    this.image,
    this.expiryDate,
    required this.active,
    required this.quantity,
    required this.price,
    this.salePrice,
    required this.promotion,
    required this.minimumQuantity,
    this.maximumQuantity,
    this.inventoryId,
    this.supplierId,
    required this.createdAt,
    required this.updatedAt,
    required this.isFinalLevel,
    // this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      brandId: json['brand_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      picture: json['picture'] as String?,
      image: json['image'] as String?,
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.tryParse(json['expiry_date'] as String)
              : null,
      active: (json['active'] as int? ?? 0) == 1,
      quantity: json['quantity'] as int? ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      salePrice:
          json['sale_price'] != null
              ? double.tryParse(json['sale_price'].toString())
              : null,
      promotion: json['promotion'] as int? ?? 0,
      minimumQuantity: json['minimum_quantity'] as int? ?? 0,
      maximumQuantity: json['maximum_quantity'] as int?,
      inventoryId: json['inventory_id'] as int?,
      supplierId: json['supplier_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isFinalLevel: (json['is_final_level'] as int? ?? 0) == 1,
      // category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'barcode': barcode,
      'brand_id': brandId,
      'category_id': categoryId,
      'name': name,
      'picture': picture,
      'image': image,
      'expiry_date': expiryDate?.toIso8601String(),
      'active': active ? 1 : 0,
      'quantity': quantity,
      'price': price,
      'sale_price': salePrice,
      'promotion': promotion,
      'minimum_quantity': minimumQuantity,
      'maximum_quantity': maximumQuantity,
      'inventory_id': inventoryId,
      'supplier_id': supplierId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_final_level': isFinalLevel ? 1 : 0,
    };
  }
}
