import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart' as app_user;
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

/// Enhancement 3: Profile screen that works for both dummyjson and Firebase
/// logins. For Firebase users it exposes update-username, change-password, and
/// delete-account actions. Both login types get a Logout button.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileData> _profileFuture;
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  /// Reload profile (called after updates).
  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<_ProfileData> _loadProfile() async {
    final loginType = await _userService.getLoginType();
    final user = await _userService.getUser();

    // Fetch extra fields stored by the signup screen.
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getString('age') ?? '';
    final contactNo = prefs.getString('contactNo') ?? '';

    return _ProfileData(
      user: user,
      loginType: loginType,
      age: age,
      contactNo: contactNo,
    );
  }

  // ───── Actions ─────

  Future<void> _logout(BuildContext context) async {
    await _userService.signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  Future<void> _showUpdateUsernameDialog() async {
    final controller = TextEditingController();

    final newUsername = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Username'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'New username',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brandNavy),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newUsername == null || newUsername.isEmpty) return;

    try {
      await _userService.updateUsername(newUsername);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated!')),
      );
      _refreshProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: newPwCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password (min 6 chars)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brandNavy),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Change', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (newPwCtrl.text.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 chars.')),
      );
      return;
    }

    try {
      await _userService.resetPasswordFromCurrentPassword(
        currentPwCtrl.text,
        newPwCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final pwCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'This action is irreversible. Enter your password to confirm.',
              fontSize: 13.sp,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || pwCtrl.text.isEmpty) return;

    try {
      await _userService.deleteAccount(pwCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted.')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  // ───── UI ─────

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: CustomText(text: 'Failed to load profile.', fontSize: 14.sp),
          );
        }

        final profile = snapshot.data;

        if (profile == null || profile.user.username.isEmpty) {
          return Center(
            child: CustomText(text: 'Not signed in.', fontSize: 14.sp),
          );
        }

        final user = profile.user;
        final isFirebase = profile.loginType == LoginType.firebase;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                // ── Avatar / name card ──
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.65,
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.h),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: user.image.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: user.image,
                                        width: 100.r,
                                        height: 100.r,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) {
                                          return Icon(
                                            Icons.person,
                                            size: 50.sp,
                                          );
                                        },
                                      )
                                    : Icon(Icons.person, size: 50.sp),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            CustomText(
                              text:
                                  '${user.firstName} ${user.lastName}'.trim(),
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 5.h),
                            CustomText(
                              text: '@${user.username}',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                            if (isFirebase) ...[
                              SizedBox(height: 4.h),
                              CustomText(
                                text: 'Firebase Account',
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Info card ──
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.email_outlined,
                          'Email',
                          user.email,
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        if (!isFirebase) ...[
                          _buildInfoRow(Icons.wc, 'Gender', user.gender),
                          Divider(height: 1, color: Colors.grey.shade300),
                        ],
                        if (profile.age.isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.cake_outlined,
                            'Age',
                            profile.age,
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                        ],
                        if (profile.contactNo.isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.phone_outlined,
                            'Contact',
                            profile.contactNo,
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                        ],
                        _buildInfoRow(
                          Icons.badge_outlined,
                          'User ID',
                          '#${user.id}',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Firebase-only actions ──
                if (isFirebase) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: Colors.amber.shade800,
                          ),
                          title: CustomText(
                            text: 'Update Username',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showUpdateUsernameDialog,
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        ListTile(
                          leading: Icon(
                            Icons.lock_reset,
                            color: Colors.amber.shade800,
                          ),
                          title: CustomText(
                            text: 'Change Password',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showChangePasswordDialog,
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          title: CustomText(
                            text: 'Delete Account',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.red,
                          ),
                          onTap: _showDeleteAccountDialog,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // ── Logout ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () => _logout(context),
                    icon: Icon(Icons.logout, size: 18.sp),
                    label: CustomText(
                      text: 'Log Out',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.amber.shade800),
          SizedBox(width: 10.w),
          CustomText(text: label, fontSize: 13.sp, fontWeight: FontWeight.w600),
          const Spacer(),
          Flexible(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal data class to bundle profile info for the FutureBuilder.
class _ProfileData {
  final app_user.User user;
  final LoginType loginType;
  final String age;
  final String contactNo;

  _ProfileData({
    required this.user,
    required this.loginType,
    this.age = '',
    this.contactNo = '',
  });
}
