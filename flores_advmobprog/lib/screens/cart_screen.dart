import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

/// Enhancement 1:
/// CartScreen renders the Cart API data managed by CartProvider.
///
/// Every cart item is clickable and opens the SAME ProductDetailScreen
/// already used by ProductScreen, satisfying the screen-widget reuse
/// requirement of Lab Activity 3.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();

    // Enhancement 3:
    // Load only the cart belonging to the configured user ID.
    //
    // addPostFrameCallback is used because CartProvider calls
    // notifyListeners(), which should not happen while the first widget
    // build is still in progress.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<CartProvider>().loadUserCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: cartProvider.loadUserCart,
        child: _buildBody(cartProvider),
      ),
    );
  }

  Widget _buildBody(CartProvider cartProvider) {
    if (cartProvider.isLoading && cartProvider.products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 220.h),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (cartProvider.products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        children: [
          SizedBox(height: 100.h),
          Icon(Icons.shopping_cart_outlined, size: 72.sp),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Your cart is empty',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Open a Bulldog Exchange product and tap Add to Cart.',
            fontSize: 14.sp,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // Enhancement 3:
          // Display which user ID is currently being used for the Cart API.
          CustomText(
            text: 'Cart API user ID: ${cartProvider.userId}',
            fontSize: 12.sp,
            textAlign: TextAlign.center,
          ),

          if (cartProvider.errorMessage != null) ...[
            SizedBox(height: 12.h),
            CustomText(
              text: 'API note: ${_cleanError(cartProvider.errorMessage!)}',
              fontSize: 11.sp,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'My Cart',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 3.h),
                  CustomText(
                    text:
                        'User ${cartProvider.userId} · '
                        '${cartProvider.totalQuantity} item(s)',
                    fontSize: 13.sp,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh cart',
              onPressed: cartProvider.isLoading
                  ? null
                  : () {
                      cartProvider.loadUserCart();
                    },
              icon: cartProvider.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Enhancement 1:
        // The items rendered from the cart are clickable and navigate to the
        // same ProductDetailScreen used by the main product/article list.
        ...cartProvider.products.map(
          (cartProduct) => _buildCartCard(context, cartProvider, cartProduct),
        ),

        SizedBox(height: 16.h),
        _buildSummary(cartProvider),

        if (cartProvider.errorMessage != null) ...[
          SizedBox(height: 12.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomText(
                      text:
                          'The local cart is still available. '
                          'API message: '
                          '${_cleanError(cartProvider.errorMessage!)}',
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCartCard(
    BuildContext context,
    CartProvider cartProvider,
    CartProduct cartProduct,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: InkWell(
        // Enhancement 1:
        // A cart item reuses ProductDetailScreen instead of creating another
        // separate details widget.
        onTap: () => _openProductDetails(cartProduct),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(cartProduct.thumbnail),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: cartProduct.title,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      text: '₱${cartProduct.price.toStringAsFixed(2)}',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text:
                          'Subtotal: '
                          '₱${cartProduct.discountedTotal.toStringAsFixed(2)}',
                      fontSize: 12.sp,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _quantityButton(
                          tooltip: 'Decrease quantity',
                          icon: Icons.remove,
                          onPressed: () {
                            cartProvider.decreaseQuantity(cartProduct.id);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: CustomText(
                            text: '${cartProduct.quantity}',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _quantityButton(
                          tooltip: 'Increase quantity',
                          icon: Icons.add,
                          onPressed: () {
                            cartProvider.increaseQuantity(cartProduct.id);
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Remove product',
                          icon: Icon(Icons.delete_outline, size: 21.sp),
                          onPressed: () {
                            _confirmRemove(cartProvider, cartProduct);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 34.w,
      height: 34.w,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
      ),
    );
  }

  Widget _buildSummary(CartProvider cartProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _summaryRow('Products', '${cartProvider.totalProducts}'),
            SizedBox(height: 6.h),
            _summaryRow('Total quantity', '${cartProvider.totalQuantity}'),
            SizedBox(height: 6.h),
            _summaryRow(
              'Original total',
              '₱${cartProvider.total.toStringAsFixed(2)}',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1),
            ),
            _summaryRow(
              'Cart total',
              '₱${cartProvider.discountedTotal.toStringAsFixed(2)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            text: label,
            fontSize: bold ? 15.sp : 13.sp,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        CustomText(
          text: value,
          fontSize: bold ? 17.sp : 13.sp,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildProductImage(String source) {
    final placeholder = Container(
      width: 90.w,
      height: 100.h,
      alignment: Alignment.center,
      child: Icon(Icons.shopping_bag_outlined, size: 36.sp),
    );

    if (source.isEmpty) {
      return placeholder;
    }

    if (source.startsWith('assets/')) {
      return SizedBox(
        width: 90.w,
        height: 100.h,
        child: Image.asset(
          source,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => placeholder,
        ),
      );
    }

    return SizedBox(
      width: 90.w,
      height: 100.h,
      child: CachedNetworkImage(
        imageUrl: source,
        fit: BoxFit.contain,
        placeholder: (_, _) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }

  /// Enhancement 1:
  /// Resolve the selected CartProduct to our Product model before opening the
  /// existing ProductDetailScreen.
  ///
  /// Bulldog Exchange products are matched by their product ID. If an API
  /// cart contains a DummyJSON product outside our local Bulldog catalog, a
  /// safe Product object is built from the available CartProduct data so the
  /// SAME detail screen can still be reused.
  Future<void> _openProductDetails(CartProduct cartProduct) async {
    Product selectedProduct;

    try {
      final products = await _productService.getAllProducts();

      selectedProduct = products.firstWhere(
        (product) => product.id == cartProduct.id,
        orElse: () => _productFromCartProduct(cartProduct),
      );
    } catch (_) {
      selectedProduct = _productFromCartProduct(cartProduct);
    }

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: selectedProduct),
      ),
    );
  }

  Product _productFromCartProduct(CartProduct cartProduct) {
    return Product(
      id: cartProduct.id,
      title: cartProduct.title,
      description: 'Product loaded from the Cart API for the selected user.',
      category: 'Cart Item',
      price: cartProduct.price,
      discountPercentage: cartProduct.discountPercentage,
      rating: 0,
      stock: cartProduct.quantity,
      tags: const ['Cart API'],
      brand: 'Bulldog Exchange',
      sku: 'CART-${cartProduct.id}',
      weight: 0,
      dimensions: ProductDimensions(width: 0, height: 0, depth: 0),
      warrantyInformation: '',
      shippingInformation: 'Available for campus pickup at NU Manila',
      availabilityStatus: 'In Cart',
      reviews: const [],
      returnPolicy: 'Subject to Bulldogs Exchange store policy',
      minimumOrderQuantity: 1,
      meta: ProductMeta(createdAt: '', updatedAt: '', barcode: '', qrCode: ''),
      images: cartProduct.thumbnail.isEmpty
          ? const []
          : [cartProduct.thumbnail],
      thumbnail: cartProduct.thumbnail,
    );
  }

  Future<void> _confirmRemove(
    CartProvider cartProvider,
    CartProduct cartProduct,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove item?'),
          content: Text('Remove ${cartProduct.title} from your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      cartProvider.removeProduct(cartProduct.id);
    }
  }

  String _cleanError(String message) {
    return message.replaceFirst('Exception: ', '');
  }
}
