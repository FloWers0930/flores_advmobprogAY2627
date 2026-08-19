import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

/// Lab Activity 3:
/// CartProvider connects CartService with the application screens.
///
/// Enhancement 3:
/// - Loads a cart using one user ID.
/// - Calls the add-to-cart API.
/// - Keeps local cart changes visible during the current app session.
/// - Prevents removed API products from coming back after navigation/refresh.
class CartProvider extends ChangeNotifier {
  CartProvider({CartService? cartService, this.userId = 1})
    : _cartService = cartService ?? CartService(),
      _cart = Cart.empty(userId: userId);

  final CartService _cartService;

  /// Only one user's cart is shown.
  final int userId;

  Cart _cart;

  bool _isLoading = false;
  String? _errorMessage;

  /// Product IDs removed by the user during the current app session.
  ///
  /// This is important because DummyJSON returns the original cart again
  /// whenever the cart endpoint is requested. Without this set, a deleted
  /// item would appear again after the cart is reloaded.
  final Set<int> _removedProductIds = <int>{};

  Cart get cart => _cart;

  List<CartProduct> get products => List.unmodifiable(_cart.products);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get totalProducts => _cart.totalProducts;

  int get totalQuantity => _cart.totalQuantity;

  double get total => _cart.total;

  double get discountedTotal => _cart.discountedTotal;

  bool get isEmpty => _cart.products.isEmpty;

  /// Enhancement 3:
  /// Loads the cart belonging to the configured user ID.
  Future<void> loadUserCart() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Keep a copy of the cart that already exists locally.
      final localProducts = List<CartProduct>.from(_cart.products);

      final apiCart = await _cartService.getCartByUserId(userId);

      if (apiCart == null) {
        _cart = _recalculateCart(localProducts);
        return;
      }

      /// BUG FIX:
      /// Ignore API products that the user already removed locally.
      ///
      /// DummyJSON does not permanently save our remove action, so the API
      /// would otherwise send these products back every time Cart is loaded.
      final mergedProducts = apiCart.products
          .where((product) => !_removedProductIds.contains(product.id))
          .toList();

      /// Preserve locally changed or locally added products.
      for (final localProduct in localProducts) {
        if (_removedProductIds.contains(localProduct.id)) {
          continue;
        }

        final existingIndex = mergedProducts.indexWhere(
          (apiProduct) => apiProduct.id == localProduct.id,
        );

        if (existingIndex >= 0) {
          /// Local version wins because it may contain a quantity change
          /// or Bulldog Exchange themed data.
          mergedProducts[existingIndex] = localProduct;
        } else {
          mergedProducts.add(localProduct);
        }
      }

      _cart = _recalculateCart(mergedProducts, cartId: apiCart.id);
    } catch (error) {
      _errorMessage = error.toString();

      /// Do not erase the current local cart when the API fails.
      if (_cart.userId != userId) {
        _cart = Cart.empty(userId: userId);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enhancement 3:
  /// Sends a product through CartService to the DummyJSON Add Cart endpoint
  /// and also stores the result locally during the current app session.
  Future<void> addProduct({required Product product, int quantity = 1}) async {
    if (quantity <= 0) {
      return;
    }

    _errorMessage = null;

    /// If this product was previously removed, adding it again is allowed.
    _removedProductIds.remove(product.id);

    try {
      await _cartService.addToCart(
        userId: userId,
        productId: product.id,
        quantity: quantity,
      );
    } catch (error) {
      /// DummyJSON mutations are simulated, so local state is still updated.
      _errorMessage = error.toString();
    }

    final updatedProducts = List<CartProduct>.from(_cart.products);

    final existingIndex = updatedProducts.indexWhere(
      (item) => item.id == product.id,
    );

    if (existingIndex >= 0) {
      final existing = updatedProducts[existingIndex];

      final newQuantity = existing.quantity + quantity;

      final newTotal = product.price * newQuantity;

      final newDiscountedTotal =
          newTotal * (1 - (product.discountPercentage / 100));

      updatedProducts[existingIndex] = existing.copyWith(
        title: product.title,
        price: product.price,
        quantity: newQuantity,
        total: newTotal,
        discountPercentage: product.discountPercentage,
        discountedTotal: newDiscountedTotal,
        thumbnail: product.thumbnail,
      );
    } else {
      final productTotal = product.price * quantity;

      final productDiscountedTotal =
          productTotal * (1 - (product.discountPercentage / 100));

      updatedProducts.add(
        CartProduct(
          id: product.id,
          title: product.title,
          price: product.price,
          quantity: quantity,
          total: productTotal,
          discountPercentage: product.discountPercentage,
          discountedTotal: productDiscountedTotal,
          thumbnail: product.thumbnail,
        ),
      );
    }

    _cart = _recalculateCart(updatedProducts);

    notifyListeners();
  }

  /// Increase one cart product quantity locally.
  void increaseQuantity(int productId) {
    final updatedProducts = _cart.products.map((item) {
      if (item.id != productId) {
        return item;
      }

      final newQuantity = item.quantity + 1;

      final newTotal = item.price * newQuantity;

      final newDiscountedTotal =
          newTotal * (1 - (item.discountPercentage / 100));

      return item.copyWith(
        quantity: newQuantity,
        total: newTotal,
        discountedTotal: newDiscountedTotal,
      );
    }).toList();

    _cart = _recalculateCart(updatedProducts);

    notifyListeners();
  }

  /// Decrease quantity.
  ///
  /// If quantity reaches zero, the product is treated as removed.
  void decreaseQuantity(int productId) {
    final updatedProducts = <CartProduct>[];

    for (final item in _cart.products) {
      if (item.id != productId) {
        updatedProducts.add(item);
        continue;
      }

      final newQuantity = item.quantity - 1;

      if (newQuantity <= 0) {
        /// Remember the deletion so API refresh cannot restore it.
        _removedProductIds.add(item.id);
        continue;
      }

      final newTotal = item.price * newQuantity;

      final newDiscountedTotal =
          newTotal * (1 - (item.discountPercentage / 100));

      updatedProducts.add(
        item.copyWith(
          quantity: newQuantity,
          total: newTotal,
          discountedTotal: newDiscountedTotal,
        ),
      );
    }

    _cart = _recalculateCart(updatedProducts);

    notifyListeners();
  }

  /// Removes a product and remembers its ID during this app session.
  void removeProduct(int productId) {
    _removedProductIds.add(productId);

    final updatedProducts = _cart.products
        .where((product) => product.id != productId)
        .toList();

    _cart = _recalculateCart(updatedProducts);

    notifyListeners();
  }

  /// Recalculate all totals whenever cart state changes.
  Cart _recalculateCart(List<CartProduct> products, {int? cartId}) {
    final total = products.fold<double>(
      0,
      (sum, product) => sum + product.total,
    );

    final discountedTotal = products.fold<double>(
      0,
      (sum, product) => sum + product.discountedTotal,
    );

    final totalQuantity = products.fold<int>(
      0,
      (sum, product) => sum + product.quantity,
    );

    return Cart(
      id: cartId ?? _cart.id,
      products: products,
      total: total,
      discountedTotal: discountedTotal,
      userId: userId,
      totalProducts: products.length,
      totalQuantity: totalQuantity,
    );
  }
}
