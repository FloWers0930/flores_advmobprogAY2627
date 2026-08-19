class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  const Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  /// Converts the JSON returned by DummyJSON into a Cart model.
  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];

    final products = rawProducts is List
        ? rawProducts
              .whereType<Map>()
              .map(
                (item) => CartProduct.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <CartProduct>[];

    return Cart(
      id: _toInt(json['id']),
      products: products,
      total: _toDouble(json['total']),
      discountedTotal: _toDouble(json['discountedTotal']),
      userId: _toInt(json['userId']),
      totalProducts: _toInt(json['totalProducts']) != 0
          ? _toInt(json['totalProducts'])
          : products.length,
      totalQuantity: _toInt(json['totalQuantity']) != 0
          ? _toInt(json['totalQuantity'])
          : products.fold<int>(0, (sum, product) => sum + product.quantity),
    );
  }

  /// Creates an empty cart for a specific user.
  factory Cart.empty({required int userId}) {
    return Cart(
      id: 0,
      products: const [],
      total: 0,
      discountedTotal: 0,
      userId: userId,
      totalProducts: 0,
      totalQuantity: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((product) => product.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }

  Cart copyWith({
    int? id,
    List<CartProduct>? products,
    double? total,
    double? discountedTotal,
    int? userId,
    int? totalProducts,
    int? totalQuantity,
  }) {
    return Cart(
      id: id ?? this.id,
      products: products ?? this.products,
      total: total ?? this.total,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      userId: userId ?? this.userId,
      totalProducts: totalProducts ?? this.totalProducts,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }
}

class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['price']);
    final quantity = _toInt(json['quantity']);
    final discountPercentage = _toDouble(json['discountPercentage']);

    final calculatedTotal = price * quantity;

    // Some DummyJSON responses/documentation use discountedTotal while
    // simulated cart responses may expose discountedPrice. Supporting both
    // keeps this model tolerant of either response shape.
    final apiDiscountedValue =
        json['discountedTotal'] ?? json['discountedPrice'];

    final calculatedDiscountedTotal =
        calculatedTotal * (1 - (discountPercentage / 100));

    return CartProduct(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      price: price,
      quantity: quantity,
      total: json['total'] == null ? calculatedTotal : _toDouble(json['total']),
      discountPercentage: discountPercentage,
      discountedTotal: apiDiscountedValue == null
          ? calculatedDiscountedTotal
          : _toDouble(apiDiscountedValue),
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }

  CartProduct copyWith({
    int? id,
    String? title,
    double? price,
    int? quantity,
    double? total,
    double? discountPercentage,
    double? discountedTotal,
    String? thumbnail,
  }) {
    return CartProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
