import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Screens
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

  static const List<String> _pageTitles = ['Shop', 'Chat', 'Profile'];

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
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                )
              : CustomText(
                  text: _pageTitles[_selectedIndex],
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            // Enhancement 3: the theme switch is no longer placed on the
            // product list. This Settings button opens the dedicated page.
            IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (page) {
            setState(() => _selectedIndex = page);
          },
          children: const <Widget>[
            ProductScreen(),
            _PlaceholderPage(
              icon: Icons.chat_bubble_outline,
              message: 'Chat page',
            ),
            _PlaceholderPage(
              icon: Icons.person_outline,
              message: 'Profile page',
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    _pageController.jumpToPage(value);
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
