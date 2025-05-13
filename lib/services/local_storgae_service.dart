import 'dart:convert';
import 'package:almalhy_store/cubit/cart/cart_state.dart';
import 'package:almalhy_store/models/auth_response.dart';
import 'package:almalhy_store/models/cinfirmed_cart_model.dart';
import 'package:almalhy_store/models/city_model.dart';
import 'package:almalhy_store/models/product_model.dart';
import 'package:almalhy_store/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyAuthResponse = 'KEY_AUTH_RESPONSE';
  static const _keyCities = 'KEY_CITIES';
  static const _keyCart = 'KEY_CART';
  static const _keyConfirmedPrefix = 'KEY_CONFIRMED_CARTS_';

  static String _confirmedKey(String userId) => '$_keyConfirmedPrefix$userId';

  /// Save the cart: each item as { product: <ProductModel JSON>, quantity: <int> }
  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        items
            .map((i) => {'product': i.product.toJson(), 'quantity': i.quantity})
            .toList();
    await prefs.setString(_keyCart, jsonEncode(jsonList));
  }

  /// Load the cart back into memory, rebuilding each ProductModel from JSON
  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCart);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) {
      final map = e as Map<String, dynamic>;
      final productJson = map['product'] as Map<String, dynamic>;
      final product = ProductModel.fromJson(productJson);
      final quantity = map['quantity'] as int;
      return CartItem(product: product, quantity: quantity);
    }).toList();
  }

  /// Persist the entire AuthResponse (including user, token, etc.)
  static Future<void> saveAuthResponse(AuthResponse resp) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(resp.toJson());
    await prefs.setString(_keyAuthResponse, jsonString);
  }

  /// Retrieve the saved AuthResponse, or null if none found
  static Future<AuthResponse?> getAuthResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyAuthResponse);
    if (jsonString == null) return null;
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return AuthResponse.fromJson(map);
  }

  /// Shortcut to just grab the stored bearer token, or null
  static Future<String?> getToken() async {
    final auth = await getAuthResponse();
    return auth?.token;
  }

  /// Load only the UserModel from storage
  static Future<UserModel?> loadUser() async {
    final auth = await getAuthResponse();
    return auth?.user;
  }

  /// Remove stored AuthResponse (e.g. on logout)
  static Future<void> clearAuthResponse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthResponse);
  }

  /// Persist the list of cities as a JSON array of maps.
  static Future<void> saveCities(List<CityModel> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cities.map((c) => c.toJson()).toList();
    await prefs.setString(_keyCities, jsonEncode(jsonList));
  }

  /// Load the saved cities, or null if none.
  static Future<List<CityModel>?> getSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCities);
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Remove stored cities.
  static Future<void> clearCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCities);
  }

  /// Replace only the `user` inside the saved AuthResponse
  static Future<void> updateStoredUser(UserModel newUser) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAuthResponse);
    if (raw == null) return;
    final old = AuthResponse.fromJson(jsonDecode(raw));
    final updated = AuthResponse(
      user: newUser,
      token: old.token,
      otp: old.otp,
      message: old.message,
    );
    await saveAuthResponse(updated);
  }

  /// Save a confirmed cart for the *current* user
  static Future<void> saveConfirmedCart(ConfirmedCart cart) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = await getAuthResponse();
    final userId = auth?.user.id;
    if (userId == null) throw Exception('No user logged in');

    final key = _confirmedKey(userId);
    final raw = prefs.getString(key);
    final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;

    // add only this user’s cart
    list.add(cart.toJson());
    await prefs.setString(key, jsonEncode(list));
  }

  /// Load *only* this user’s confirmed carts
  static Future<List<ConfirmedCart>> loadConfirmedCarts() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = await getAuthResponse();
    final userId = auth?.user.id;
    if (userId == null) return [];

    final key = _confirmedKey(userId);
    final raw = prefs.getString(key);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ConfirmedCart.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (Optional) Clear this user’s history
  static Future<void> clearConfirmedCarts() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = await getAuthResponse();
    final userId = auth?.user.id;
    if (userId == null) return;
    await prefs.remove(_confirmedKey(userId));
  }

  /// Wipes out all app‐specific keys from SharedPreferences
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthResponse);
    await prefs.remove(_keyCart);
    await prefs.remove(_keyCities);
    // Remove all per‐user confirmed orders too:
    final auth = await getAuthResponse();
    final userId = auth?.user.id;
    if (userId != null) {
      await prefs.remove(_confirmedKey(userId));
    }
  }
}
