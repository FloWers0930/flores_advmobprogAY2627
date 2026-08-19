import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load(fileName: 'assets/.env');

  runApp(const FloresAdvMobProg());
}

class FloresAdvMobProg extends StatelessWidget {
  const FloresAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    // Lab Activity 3:
    // MultiProvider is now used because the application has two pieces of
    // shared state:
    //
    // 1. ThemeProvider - controls light/dark mode.
    // 2. CartProvider  - manages the selected user's cart.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Enhancement 3:
        // Only one user's cart is rendered at a time.
        // User ID 1 is used for this laboratory implementation.
        ChangeNotifierProvider(create: (_) => CartProvider(userId: 1)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final themeProvider = context.watch<ThemeProvider>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NU Bulldogs Exchange',

            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),

            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

            initialRoute: '/home',

            routes: {
              '/home': (context) => const HomeScreen(),

              // Lab Activity 2 Enhancement 3:
              // The theme switch remains inside the dedicated Settings page.
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
