import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    // The activity still consumes the configured REST API endpoint so the
    // Model -> Service -> Screen data flow remains part of the laboratory.
    final response = await http.get(Uri.parse('$host/products?limit=10'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> apiProducts = data['products'] ?? [];

      if (apiProducts.isEmpty) {
        return [];
      }

      // Bulldog Exchange catalog adaptation:
      // The public laboratory endpoint contains generic demo products. For
      // this NU Manila version, the successful endpoint response is adapted
      // into a campus-focused Bulldog Exchange sample catalog while keeping
      // the same Product model and asynchronous service architecture.
      final itemCount = apiProducts.length < _bulldogExchangeCatalog.length
          ? apiProducts.length
          : _bulldogExchangeCatalog.length;

      return List<Product>.generate(itemCount, (index) {
        final item = Map<String, dynamic>.from(
          _bulldogExchangeCatalog[index],
        );

        // Reuse the ID returned by the API so every rendered item still has a
        // stable identifier originating from the endpoint response.
        item['id'] = apiProducts[index]['id'] ?? index + 1;
        return Product.fromJson(item);
      });
    }

    throw Exception('Failed to load Bulldog Exchange products');
  }

  // Sample National University Manila / Bulldogs Exchange catalog used for
  // the laboratory UI. Product photos are bundled as local assets so the
  // cards and details page keep working after the first app installation.
  static final List<Map<String, dynamic>> _bulldogExchangeCatalog = [
    {
      'title': 'NU Bulldogs Classic Shirt',
      'description':
          'A National University Bulldogs campus shirt in black with the iconic Bulldog mascot and NU colors. Ideal for classes, UAAP game days, and everyday campus wear.',
      'category': 'Apparel',
      'price': 339.0,
      'discountPercentage': 0.0,
      'rating': 4.9,
      'stock': 24,
      'tags': ['NU Manila', 'Bulldogs', 'Shirt', 'Campus Wear'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-SHIRT-001',
      'weight': 180.0,
      'dimensions': {'width': 28.0, 'height': 38.0, 'depth': 2.0},
      'warrantyInformation': 'Inspect item upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Available',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Perfect for showing NU school spirit.',
          'date': '2026-08-15',
          'reviewerName': 'NU Student',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE001',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_black_shirt.jpg'],
      'thumbnail': 'assets/images/products/nu_black_shirt.jpg',
    },
    {
      'title': 'NU Bulldogs ID Lace',
      'description':
          'National University Bulldogs lanyard designed for student IDs. The blue, white, and gold design matches NU colors and is practical for everyday campus use.',
      'category': 'School Essentials',
      'price': 75.0,
      'discountPercentage': 0.0,
      'rating': 5.0,
      'stock': 40,
      'tags': ['NU Manila', 'Lanyard', 'ID Lace', 'Student Essential'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-LACE-002',
      'weight': 45.0,
      'dimensions': {'width': 2.0, 'height': 90.0, 'depth': 1.0},
      'warrantyInformation': 'Inspect item upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Available',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Useful and matches the NU colors well.',
          'date': '2026-08-16',
          'reviewerName': 'Nationalian',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE002',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_lanyard.jpg'],
      'thumbnail': 'assets/images/products/nu_lanyard.jpg',
    },
    {
      'title': 'NU Bulldogs Campus Hoodie',
      'description':
          'A navy National University Bulldogs hoodie for cooler classrooms, commute days, and school events. Features bold National University and Bulldogs graphics.',
      'category': 'Apparel',
      'price': 999.0,
      'discountPercentage': 0.0,
      'rating': 4.9,
      'stock': 12,
      'tags': ['NU Manila', 'Hoodie', 'Bulldogs', 'Campus Wear'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-HOODIE-003',
      'weight': 620.0,
      'dimensions': {'width': 35.0, 'height': 45.0, 'depth': 5.0},
      'warrantyInformation': 'Inspect size and print upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Limited Stock',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Comfortable and great for campus use.',
          'date': '2026-08-14',
          'reviewerName': 'NU Student',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE003',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_hoodie.jpg'],
      'thumbnail': 'assets/images/products/nu_hoodie.jpg',
    },
    {
      'title': 'NU Bulldogs Varsity Socks',
      'description':
          'Bulldogs-themed varsity socks in NU colors. A simple campus accessory for students and supporters who want to complete their game-day look.',
      'category': 'Accessories',
      'price': 179.0,
      'discountPercentage': 0.0,
      'rating': 5.0,
      'stock': 30,
      'tags': ['NU Manila', 'Socks', 'Bulldogs', 'Accessory'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-SOCKS-004',
      'weight': 90.0,
      'dimensions': {'width': 10.0, 'height': 24.0, 'depth': 3.0},
      'warrantyInformation': 'Inspect item upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Available',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Nice NU design and easy to pair with sneakers.',
          'date': '2026-08-13',
          'reviewerName': 'Bulldogs Fan',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE004',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_socks.jpg'],
      'thumbnail': 'assets/images/products/nu_socks.jpg',
    },
    {
      'title': 'NU Bulldogs Basketball Jersey',
      'description':
          'A National University Bulldogs basketball-inspired jersey in navy, white, and gold. Designed for supporters who want a sporty NU look during games and campus events.',
      'category': 'Sportswear',
      'price': 359.0,
      'discountPercentage': 0.0,
      'rating': 4.8,
      'stock': 18,
      'tags': ['NU Manila', 'Basketball', 'Jersey', 'UAAP'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-JERSEY-005',
      'weight': 220.0,
      'dimensions': {'width': 30.0, 'height': 42.0, 'depth': 2.0},
      'warrantyInformation': 'Inspect size and print upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Available',
      'reviews': [
        {
          'rating': 5,
          'comment': 'The navy and gold look fits the Bulldogs theme.',
          'date': '2026-08-12',
          'reviewerName': 'NU Supporter',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE005',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_jersey.jpg'],
      'thumbnail': 'assets/images/products/nu_jersey.jpg',
    },
    {
      'title': 'NU Bulldog Enamel Pin',
      'description':
          'A compact Bulldog mascot enamel pin that can be attached to a bag, lanyard, jacket, or school accessory for an extra touch of National University pride.',
      'category': 'Accessories',
      'price': 135.0,
      'discountPercentage': 0.0,
      'rating': 4.7,
      'stock': 35,
      'tags': ['NU Manila', 'Bulldog', 'Pin', 'Accessory'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-PIN-006',
      'weight': 20.0,
      'dimensions': {'width': 4.0, 'height': 4.0, 'depth': 1.0},
      'warrantyInformation': 'Inspect item upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Available',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Small but looks great on my school bag.',
          'date': '2026-08-11',
          'reviewerName': 'Nationalian',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE006',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_pin.jpg'],
      'thumbnail': 'assets/images/products/nu_pin.jpg',
    },
    {
      'title': 'NU Bulldogs Trucker Cap',
      'description':
          'A navy National University Bulldogs cap featuring the Bulldog mascot and university colors. Suitable for campus events, casual wear, and supporting NU teams.',
      'category': 'Accessories',
      'price': 249.0,
      'discountPercentage': 0.0,
      'rating': 4.9,
      'stock': 16,
      'tags': ['NU Manila', 'Cap', 'Bulldogs', 'Campus Wear'],
      'brand': 'Bulldogs Exchange',
      'sku': 'NU-BE-CAP-007',
      'weight': 160.0,
      'dimensions': {'width': 20.0, 'height': 16.0, 'depth': 25.0},
      'warrantyInformation': 'Inspect item upon purchase',
      'shippingInformation': 'Available for campus pickup at NU Manila',
      'availabilityStatus': 'Available',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Good match with other NU merchandise.',
          'date': '2026-08-10',
          'reviewerName': 'Bulldogs Fan',
          'reviewerEmail': '',
        },
      ],
      'returnPolicy': 'Subject to Bulldogs Exchange store policy',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2026-08-01',
        'updatedAt': '2026-08-19',
        'barcode': 'NUBE007',
        'qrCode': '',
      },
      'images': ['assets/images/products/nu_cap.jpg'],
      'thumbnail': 'assets/images/products/nu_cap.jpg',
    },
  ];
}
