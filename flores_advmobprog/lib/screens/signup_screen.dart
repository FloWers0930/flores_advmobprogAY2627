import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';

// constants
import '../constants.dart';

// services
import '../services/user_service.dart';

// widgets
import '../widgets/custom_text.dart';

/// Enhancement 2: Firebase-based signup screen styled after dummyjson.com/users.
/// Extra profile fields (fName, lName, age, contactNo) are persisted in
/// SharedPreferences via the existing User model since the project does not use
/// Firestore. Firebase Auth holds email/password + displayName.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ───── Validation helpers ─────

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _ageValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null) return 'Age must be a number';
    if (age < 1 || age > 150) return 'Enter a valid age';
    return null;
  }

  // ───── Submit ─────

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = UserService();

      // 1. Create account in Firebase Auth.
      final credential = await userService.createAccount(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 2. Set display name to the username.
      await credential.user?.updateDisplayName(_usernameController.text.trim());
      await credential.user?.reload();

      // 3. Persist extra fields into SharedPreferences via the existing
      //    saveUserData helper, matching the User model shape.
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser!;
      await userService.saveUserData({
        'id': fbUser.uid.hashCode,
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'firstName': _fNameController.text.trim(),
        'lastName': _lNameController.text.trim(),
        'gender': '',
        'image': fbUser.photoURL ?? '',
        'accessToken': await fbUser.getIdToken() ?? '',
        'refreshToken': fbUser.refreshToken ?? '',
      });

      // Also store age & contactNo that don't exist on the User model.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('age', _ageController.text.trim());
      await prefs.setString('contactNo', _contactNoController.text.trim());

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on fb_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    }
  }

  // ───── UI helpers ─────

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Create Account',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/nubdexchange_logo.png',
                        width: 48.w,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: 'Sign Up',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        text: 'Create your NUBD Exchange account',
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // First Name & Last Name row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fNameController,
                        decoration: _fieldDecoration(
                          'First Name',
                          icon: Icons.person_outline,
                        ),
                        validator: (v) => _requiredValidator(v, 'First name'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _lNameController,
                        decoration: _fieldDecoration(
                          'Last Name',
                          icon: Icons.person_outline,
                        ),
                        validator: (v) => _requiredValidator(v, 'Last name'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Age & Contact Number row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          'Age',
                          icon: Icons.cake_outlined,
                        ),
                        validator: _ageValidator,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _contactNoController,
                        keyboardType: TextInputType.phone,
                        decoration: _fieldDecoration(
                          'Contact No.',
                          icon: Icons.phone_outlined,
                        ),
                        validator: (v) => _requiredValidator(v, 'Contact no.'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: _fieldDecoration(
                    'Username',
                    icon: Icons.alternate_email,
                  ),
                  validator: (v) => _requiredValidator(v, 'Username'),
                ),

                SizedBox(height: 14.h),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration(
                    'Email Address',
                    icon: Icons.email_outlined,
                  ),
                  validator: _emailValidator,
                ),

                SizedBox(height: 14.h),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _fieldDecoration(
                    'Password',
                    icon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _passwordValidator,
                ),

                SizedBox(height: 28.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: _isLoading ? null : _createAccount,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : CustomText(
                              text: 'Create Account',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Navigate back to sign-in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Already have an account? ',
                      fontSize: 13.sp,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CustomText(
                        text: 'Sign In',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
