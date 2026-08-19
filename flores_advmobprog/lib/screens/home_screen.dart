import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Screens
import 'cart_screen.dart';
import 'product_screen.dart';

// Widgets
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  static const List<String> _pageTitles = ['Shop', 'Cart', 'Profile'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          title: _selectedIndex == 0
              ? Image.asset('assets/images/nubdexchange_logo.png', scale: 11.sp)
              : CustomText(
                  text: _pageTitles[_selectedIndex],
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),

        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
          children: const [
            ProductScreen(),

            // Enhancement 1:
            // Cart screen renders the cart belonging to one user.
            CartScreen(),

            _PlaceholderPage(
              icon: Icons.person_outline,
              message: 'Profile page',
            ),
          ],
        ),

        // Enhancement 2:
        // Chat is now a FloatingActionButton.
        //
        // It is hidden only when Cart is selected, as required
        // by Lab Activity 3.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                tooltip: 'Chat',
                onPressed: _openChat,
                child: const Icon(Icons.chat_bubble_outline),
              ),

        // Put Chat on the right instead of occupying the middle
        // of the navigation bar. This allows Cart to be perfectly centered.
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        // Shop, Cart and Profile now receive equal space.
        // Because there are exactly three items, Cart is centered.
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTappedBar,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shop_2_outlined),
              selectedIcon: Icon(Icons.shop_2),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    _pageController.jumpToPage(value);

    setState(() {
      _selectedIndex = value;
    });
  }

  // Enhancement 2:
  // Chat is opened using the FloatingActionButton instead
  // of being another bottom navigation destination.
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ChatPage()),
    );
  }
}

class _ChatPage extends StatelessWidget {
  const _ChatPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Chat',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: const _PlaceholderPage(
        icon: Icons.chat_bubble_outline,
        message: 'Chat page',
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _PlaceholderPage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.sp),
          SizedBox(height: 8.h),
          CustomText(text: message, fontSize: 16.sp),
        ],
      ),
    );
  }
}
