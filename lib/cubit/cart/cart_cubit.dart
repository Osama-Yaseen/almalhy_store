import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:almalhy_store/models/product_model.dart';
import 'cart_state.dart';

/// Manages a shopping cart, persisting changes to local storage.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartEmpty()) {
    _init();
  }

  // Internal map: productId → CartItem
  final Map<int, CartItem> _items = {};

  /// Load saved cart from local storage on startup
  Future<void> _init() async {
    final savedItems = await LocalStorageService.loadCart();
    for (final item in savedItems) {
      _items[item.product.id] = item;
    }
    _emit();
  }

  /// Persist current cart to local storage
  void _persist() {
    LocalStorageService.saveCart(_items.values.toList());
  }

  /// Emit the appropriate state (empty vs loaded) and persist
  void _emit() {
    if (_items.isEmpty) {
      emit(const CartEmpty());
    } else {
      emit(CartLoaded(_items.values.toList()));
    }
    _persist();
  }

  /// Add first of [product]
  void add(ProductModel product) {
    if (!_items.containsKey(product.id)) {
      _items[product.id] = CartItem(product: product, quantity: 1);
      _emit();
    }
  }

  void clear() {
    _items.clear();
    _emit();
  }

  /// Increment qty, up to product.quantity
  void increment(ProductModel product) {
    final entry = _items[product.id];
    if (entry != null && entry.quantity < product.quantity) {
      _items[product.id] = CartItem(
        product: product,
        quantity: entry.quantity + 1,
      );
      _emit();
    }
  }

  /// Decrement qty (remove if hits zero)
  void decrement(ProductModel product) {
    final entry = _items[product.id];
    if (entry == null) return;

    if (entry.quantity > 1) {
      _items[product.id] = CartItem(
        product: product,
        quantity: entry.quantity - 1,
      );
    } else {
      _items.remove(product.id);
    }

    _emit();
  }
}
