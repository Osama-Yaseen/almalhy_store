import 'package:almalhy_store/models/product_model.dart';

/// A single line‐item in the cart
class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  /// Deserialize a CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  /// Serialize this CartItem to JSON
  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }
}

/// Base class for cart states
abstract class CartState {
  const CartState();
}

/// When there’s nothing in the cart
class CartEmpty extends CartState {
  const CartEmpty();
}

/// When there are items
class CartLoaded extends CartState {
  final List<CartItem> items;
  const CartLoaded(this.items);

  /// total item count
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  /// grand total price
  double get totalPrice =>
      items.fold(0, (sum, i) => sum + i.quantity * i.product.price);
}
