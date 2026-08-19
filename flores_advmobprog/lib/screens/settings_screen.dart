import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/theme_provider.dart';

// Widgets
import '../widgets/custom_text.dart';

// Enhancement 3: dedicated Settings page. The dark/light mode switch was
// moved here so appearance controls are separated from the content screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        children: [
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              title: CustomText(
                text: 'Dark Mode',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              subtitle: CustomText(
                text: themeProvider.isDark
                    ? 'Use the dark application theme'
                    : 'Use the light application theme',
                fontSize: 12.sp,
              ),
              value: themeProvider.isDark,

              // Enhancement 3: Provider stores the selected mode and notifies
              // MaterialApp, which immediately switches light/dark themes.
              onChanged: themeProvider.setDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}
