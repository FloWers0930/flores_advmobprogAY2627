import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  /// Enhancement 3:
  /// Gets the cart that belongs to one specific user.
  ///
  /// DummyJSON returns:
  /// {
  ///   "carts": [...],
  ///   "total": 1,
  ///   "skip": 0,
  ///   "limit": 1
  /// }
  ///
  /// The activity requires rendering only one user's cart, so this method
  /// returns the first cart owned by the requested user.
  Future<Cart?> getCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cart for user $userId '
        '(HTTP ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final dynamic rawCarts = data['carts'];

    if (rawCarts is! List || rawCarts.isEmpty) {
      return null;
    }

    final firstCart = rawCarts.first;

    if (firstCart is! Map) {
      throw const FormatException(
        'Invalid cart response received from the API.',
      );
    }

    return Cart.fromJson(Map<String, dynamic>.from(firstCart));
  }

  /// Laboratory Discussion requirement:
  /// Demonstrates getById using the Cart endpoint.
  ///
  /// Example:
  /// GET https://dummyjson.com/carts/1
  Future<Cart> getCartById(int cartId) async {
    final response = await http.get(Uri.parse('$host/carts/$cartId'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cart $cartId '
        '(HTTP ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Cart.fromJson(data);
  }

  /// Enhancement 3:
  /// Sends a product ID and quantity to DummyJSON's add-cart endpoint.
  ///
  /// DummyJSON simulates the cart creation and returns the resulting Cart.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    if (userId <= 0) {
      throw ArgumentError.value(
        userId,
        'userId',
        'User ID must be greater than zero.',
      );
    }

    if (productId <= 0) {
      throw ArgumentError.value(
        productId,
        'productId',
        'Product ID must be greater than zero.',
      );
    }

    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Quantity must be greater than zero.',
      );
    }

    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to add product $productId to cart '
        '(HTTP ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Cart.fromJson(data);
  }
}
