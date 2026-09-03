import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();

  Cart? _cart;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserCart();
  }

  Future<void> _loadUserCart() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final user = await UserService().getUser();
      final carts = await _cartService.getCartsByUser(user.id);

      if (!mounted) return;

      setState(() {
        _cart = carts.isNotEmpty ? carts.first : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(onRefresh: _loadUserCart, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180.h),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 50.sp),
                  SizedBox(height: 12.h),
                  CustomText(
                    text: 'Failed to load cart',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: _errorMessage!,
                    fontSize: 13.sp,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _loadUserCart,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final cart = _cart;

    if (cart == null || cart.products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180.h),
          Center(
            child: Column(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 70.sp),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Your cart is empty',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: 'Add some products to your cart.',
                  fontSize: 14.sp,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      children: [
        CustomText(
          text: 'Shopping Cart',
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 4.h),
        CustomText(
          text:
              '${cart.totalQuantity} item${cart.totalQuantity == 1 ? '' : 's'}',
          fontSize: 14.sp,
        ),
        SizedBox(height: 16.h),

        ...cart.products.map((cartProduct) => _buildCartCard(cartProduct)),

        SizedBox(height: 12.h),

        _buildSummary(cart),

        SizedBox(height: 16.h),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout is not available yet.')),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: CustomText(
                text: 'Proceed to Checkout',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartCard(CartProduct cartProduct) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _openProductDetails(cartProduct),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CachedNetworkImage(
                  imageUrl: cartProduct.thumbnail,
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 90.w,
                    height: 90.w,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 90.w,
                    height: 90.w,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: cartProduct.title,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6.h),

                    CustomText(
                      text: '\$${cartProduct.price.toStringAsFixed(2)}',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        IconButton(
                          onPressed: cartProduct.quantity > 1
                              ? () => _changeQuantity(
                                  cartProduct,
                                  cartProduct.quantity - 1,
                                )
                              : null,
                          icon: const Icon(Icons.remove),
                          iconSize: 18.sp,
                          constraints: BoxConstraints(
                            minWidth: 32.w,
                            minHeight: 32.h,
                          ),
                          padding: EdgeInsets.zero,
                        ),

                        Container(
                          width: 35.w,
                          alignment: Alignment.center,
                          child: CustomText(
                            text: '${cartProduct.quantity}',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        IconButton(
                          onPressed: () => _changeQuantity(
                            cartProduct,
                            cartProduct.quantity + 1,
                          ),
                          icon: const Icon(Icons.add),
                          iconSize: 18.sp,
                          constraints: BoxConstraints(
                            minWidth: 32.w,
                            minHeight: 32.h,
                          ),
                          padding: EdgeInsets.zero,
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: () => _confirmRemove(cartProduct),
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 21.sp,
                          padding: EdgeInsets.zero,
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

  Widget _buildSummary(Cart cart) {
    final hasDiscount = cart.total != cart.discountedTotal;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: 'Products', fontSize: 14.sp),
                CustomText(text: '${cart.totalProducts}', fontSize: 14.sp),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: 'Quantity', fontSize: 14.sp),
                CustomText(text: '${cart.totalQuantity}', fontSize: 14.sp),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: 'Subtotal', fontSize: 14.sp),
                CustomText(
                  text: '\$${cart.total.toStringAsFixed(2)}',
                  fontSize: 14.sp,
                ),
              ],
            ),

            if (hasDiscount) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Discounted Total',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Total',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _changeQuantity(CartProduct cartProduct, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      final user = await UserService().getUser();

      final products = _cart?.products.map((product) {
        return {
          'id': product.id,
          'quantity': product.id == cartProduct.id
              ? newQuantity
              : product.quantity,
        };
      }).toList();

      if (products == null) return;

      final updatedCart = await _cartService.addToCart(
        userId: user.id,
        products: products,
      );

      if (!mounted) return;

      setState(() {
        _cart = updatedCart;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update quantity: $e')));
    }
  }

  Future<void> _confirmRemove(CartProduct cartProduct) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Product'),
          content: Text('Remove "${cartProduct.title}" from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) return;

    try {
      final user = await UserService().getUser();

      final remainingProducts = _cart?.products
          .where((product) => product.id != cartProduct.id)
          .map((product) => {'id': product.id, 'quantity': product.quantity})
          .toList();

      if (remainingProducts == null) return;

      if (remainingProducts.isEmpty) {
        if (!mounted) return;

        setState(() {
          _cart = null;
        });
        return;
      }

      final updatedCart = await _cartService.addToCart(
        userId: user.id,
        products: remainingProducts,
      );

      if (!mounted) return;

      setState(() {
        _cart = updatedCart;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove product: $e')));
    }
  }

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

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(product: selectedProduct)),
    );
  }

  Product _productFromCartProduct(CartProduct cartProduct) {
    return Product(
      id: cartProduct.id,
      title: cartProduct.title,
      description: '',
      category: '',
      price: cartProduct.price,
      discountPercentage: cartProduct.discountPercentage,
      rating: 0,
      stock: 0,
      tags: const [],
      brand: '',
      sku: '',
      weight: 0,
      dimensions: ProductDimensions(width: 0, height: 0, depth: 0),
      warrantyInformation: '',
      shippingInformation: '',
      availabilityStatus: '',
      reviews: const [],
      returnPolicy: '',
      minimumOrderQuantity: 1,
      meta: ProductMeta(createdAt: '', updatedAt: '', barcode: '', qrCode: ''),
      images: [cartProduct.thumbnail],
      thumbnail: cartProduct.thumbnail,
    );
  }
}
