import 'package:almalhy_store/models/product_model.dart';
import 'package:almalhy_store/models/user_model.dart';
import 'package:almalhy_store/cubit/cart/cart_state.dart';

/// Represents a confirmed (completed) cart/order
class ConfirmedCart {
  /// Unique identifier for this order (e.g. timestamp-based)
  final int id;

  /// The customer who placed this order
  final UserModel user;

  /// The items that were in the cart at confirmation
  final List<CartItem> items;

  /// Optional notes entered by the user
  final String notes;

  /// Delivery fee applied to this order
  final double deliveryFee;

  /// When the order was placed
  final DateTime date;

  /// Order status (e.g. "pending", "confirmed", "delivered")
  final String status;

  ConfirmedCart({
    required this.id,
    required this.user,
    required this.items,
    required this.notes,
    required this.deliveryFee,
    required this.date,
    required this.status,
  });

  factory ConfirmedCart.fromJson(Map<String, dynamic> json) {
    return ConfirmedCart(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      items:
          (json['items'] as List<dynamic>)
              .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      notes: json['notes'] as String? ?? '',
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'items': items.map((i) => i.toJson()).toList(),
    'notes': notes,
    'deliveryFee': deliveryFee,
    'date': date.toIso8601String(),
    'status': status,
  };
}

// Add a CartItem JSON helper if needed:
extension CartItemJson on CartItem {
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}
