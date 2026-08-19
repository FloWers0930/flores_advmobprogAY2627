import 'package:flutter_test/flutter_test.dart';

import 'package:flores_mobile/models/product_model.dart';
import 'package:flores_mobile/providers/theme_provider.dart';

void main() {
  test('ThemeProvider changes dark mode value', () {
    final provider = ThemeProvider();

    expect(provider.isDark, isFalse);

    provider.setDarkMode(true);
    expect(provider.isDark, isTrue);

    provider.setDarkMode(false);
    expect(provider.isDark, isFalse);
  });

  test('Product model converts API JSON into a Dart object', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Sample Product',
      'description': 'Sample Description',
      'category': 'sample-category',
      'price': 99.99,
      'discountPercentage': 10,
      'rating': 4.5,
      'stock': 5,
      'tags': ['sample'],
      'brand': 'NU',
      'sku': 'NU-001',
      'weight': 1,
      'dimensions': {'width': 1, 'height': 2, 'depth': 3},
      'warrantyInformation': '1 year',
      'shippingInformation': 'Ships tomorrow',
      'availabilityStatus': 'In Stock',
      'reviews': [],
      'returnPolicy': '7 days',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '',
        'updatedAt': '',
        'barcode': '',
        'qrCode': '',
      },
      'images': ['https://example.com/product.png'],
      'thumbnail': 'https://example.com/thumb.png',
    });

    expect(product.id, 1);
    expect(product.title, 'Sample Product');
    expect(product.price, 99.99);
    expect(product.dimensions.height, 2.0);
  });
}
