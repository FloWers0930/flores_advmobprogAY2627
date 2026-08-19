import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Models
import '../models/product_model.dart';

// Services
import '../services/product_service.dart';

// Screens
import 'product_detail_screen.dart';

// Widgets
import '../widgets/custom_text.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;

  // Enhancement 1: store the search text entered above the article/product
  // card list so the already-fetched API data can be filtered locally.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhancement 1: search bar added above the card list. Typing here
            // rebuilds the list and shows only matching title/brand/category.
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: 'Bulldog Exchange · NU Manila',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 4.h),
            CustomText(
              text: 'Campus merchandise for Nationalians',
              fontSize: 12.sp,
            ),
            SizedBox(height: 16.h),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 42.sp),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Unable to load products.',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: '${snapshot.error}',
                            fontSize: 12.sp,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allProducts = snapshot.data ?? [];

                // Enhancement 1: filtering is case-insensitive and does not
                // make another HTTP request for every character typed.
                final normalizedQuery = _searchQuery.toLowerCase();
                final products = normalizedQuery.isEmpty
                    ? allProducts
                    : allProducts.where((product) {
                        return product.title.toLowerCase().contains(
                                  normalizedQuery,
                                ) ||
                            product.brand.toLowerCase().contains(
                                  normalizedQuery,
                                ) ||
                            product.category.toLowerCase().contains(
                                  normalizedQuery,
                                );
                      }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: CustomText(
                        text: _searchQuery.isEmpty
                            ? 'No products found.'
                            : 'No results for "$_searchQuery".',
                        fontSize: 14.sp,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: InkWell(
                        // Enhancement 2: clicking/tapping a card opens a
                        // dedicated details page for the selected API object.
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildProductImage(product.thumbnail),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text:
                                        '₱${product.price.toStringAsFixed(2)}',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String source) {
    if (source.startsWith('assets/')) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.r),
        child: Image.asset(
          source,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Center(
            child: Icon(Icons.image_not_supported_outlined, size: 32.sp),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(Icons.image_not_supported_outlined, size: 32.sp),
      ),
    );
  }
}
