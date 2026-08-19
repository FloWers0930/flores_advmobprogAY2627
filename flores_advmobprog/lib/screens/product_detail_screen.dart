import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Models
import '../models/product_model.dart';

// Providers
import '../providers/cart_provider.dart';

// Widgets
import '../widgets/custom_text.dart';

/// Lab Activity 2 Enhancement 2:
/// This is the dedicated details screen opened when a product card is tapped.
///
/// Lab Activity 3 Enhancement 1:
/// The SAME ProductDetailScreen is also reused when a cart item is tapped.
///
/// Lab Activity 3 Enhancement 3:
/// Products can now be added to the selected user's cart through CartProvider.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imageController = PageController();

  int _imageIndex = 0;

  // Enhancement 3:
  // Quantity that will be passed when adding the product to the cart.
  int _quantity = 1;

  bool _isAddingToCart = false;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final images = product.images.isNotEmpty
        ? product.images
        : product.thumbnail.isNotEmpty
        ? [product.thumbnail]
        : <String>[];

    final discountedPrice =
        product.price * (1 - product.discountPercentage / 100);

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageGallery(images),

              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: product.brand.isNotEmpty
                          ? '${product.brand} · NU Manila · ${product.category}'
                          : product.category,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),

                    SizedBox(height: 6.h),

                    CustomText(
                      text: product.title,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      children: [
                        CustomText(
                          text: '₱${discountedPrice.toStringAsFixed(2)}',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),

                        if (product.discountPercentage > 0) ...[
                          SizedBox(width: 8.w),

                          CustomText(
                            text: '₱${product.price.toStringAsFixed(2)}',
                            fontSize: 14.sp,
                            fontStyle: FontStyle.italic,
                          ),

                          SizedBox(width: 8.w),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: CustomText(
                              text:
                                  '-${product.discountPercentage.toStringAsFixed(0)}%',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18.sp),

                        SizedBox(width: 4.w),

                        CustomText(
                          text:
                              '${product.rating.toStringAsFixed(2)} · '
                              '${product.reviews.length} reviews',
                          fontSize: 13.sp,
                        ),

                        SizedBox(width: 12.w),

                        Expanded(
                          child: CustomText(
                            text: product.availabilityStatus.isNotEmpty
                                ? product.availabilityStatus
                                : product.stock > 0
                                ? 'In Stock (${product.stock})'
                                : 'Out of Stock',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    CustomText(
                      text: 'Description',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),

                    SizedBox(height: 6.h),

                    CustomText(text: product.description, fontSize: 14.sp),

                    if (product.tags.isNotEmpty) ...[
                      SizedBox(height: 16.h),

                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: product.tags
                            .map(
                              (tag) => Chip(
                                label: CustomText(text: tag, fontSize: 12.sp),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    SizedBox(height: 20.h),

                    CustomText(
                      text: 'Details',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),

                    SizedBox(height: 6.h),

                    _buildDetailRow('SKU', product.sku),

                    if (product.weight > 0)
                      _buildDetailRow('Weight', '${product.weight} g'),

                    if (product.dimensions.width > 0 ||
                        product.dimensions.height > 0 ||
                        product.dimensions.depth > 0)
                      _buildDetailRow(
                        'Dimensions',
                        '${product.dimensions.width} x '
                            '${product.dimensions.height} x '
                            '${product.dimensions.depth} cm',
                      ),

                    if (product.minimumOrderQuantity > 0)
                      _buildDetailRow(
                        'Minimum Order',
                        '${product.minimumOrderQuantity}',
                      ),

                    _buildDetailRow('Warranty', product.warrantyInformation),

                    _buildDetailRow('Shipping', product.shippingInformation),

                    _buildDetailRow('Return Policy', product.returnPolicy),

                    if (product.reviews.isNotEmpty) ...[
                      SizedBox(height: 20.h),

                      CustomText(
                        text: 'Reviews',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),

                      SizedBox(height: 8.h),

                      ...product.reviews.map(
                        (review) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomText(
                                    text: review.reviewerName,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),

                                  SizedBox(width: 8.w),

                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.h),

                              CustomText(text: review.comment, fontSize: 13.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Enhancement 3:
      // The selected product ID and quantity are passed through CartProvider,
      // which calls CartService and the DummyJSON /carts/add endpoint.
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Decrease quantity',
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove),
                    ),

                    SizedBox(
                      width: 28.w,
                      child: CustomText(
                        text: '$_quantity',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    IconButton(
                      tooltip: 'Increase quantity',
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: FilledButton.icon(
                  onPressed: _isAddingToCart ? null : _addToCart,
                  icon: _isAddingToCart
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: Text(_isAddingToCart ? 'Adding...' : 'Add to Cart'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Enhancement 3:
  /// Adds the selected Product to the currently configured user's cart.
  Future<void> _addToCart() async {
    if (_isAddingToCart) {
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    final cartProvider = context.read<CartProvider>();

    await cartProvider.addProduct(product: widget.product, quantity: _quantity);

    if (!mounted) {
      return;
    }

    setState(() {
      _isAddingToCart = false;
    });

    final apiError = cartProvider.errorMessage;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            apiError == null
                ? '${widget.product.title} added to cart.'
                : '${widget.product.title} added to the local cart. '
                      'The API request could not be completed.',
          ),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          Expanded(
            child: CustomText(text: value, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String source) {
    if (source.isEmpty) {
      return Center(
        child: Icon(Icons.image_not_supported_outlined, size: 48.sp),
      );
    }

    if (source.startsWith('assets/')) {
      return Padding(
        padding: EdgeInsets.all(12.r),
        child: Image.asset(
          source,
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (_, _, _) => Center(
            child: Icon(Icons.image_not_supported_outlined, size: 48.sp),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, _, _) =>
          Center(child: Icon(Icons.image_not_supported_outlined, size: 48.sp)),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) {
      return SizedBox(
        height: 280.h,
        width: double.infinity,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, size: 64.sp),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 280.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _imageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _imageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildProductImage(images[index]);
            },
          ),
        ),

        if (images.length > 1)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _imageIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
