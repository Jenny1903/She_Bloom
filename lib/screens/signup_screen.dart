import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:she_bloom/constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return phone.length >= 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
  }

  void _handleSignUp() {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showSnackBar('Enter Your Name');
      return;
    }
    if (email.isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email address');
      return;
    }

    if (phone.isEmpty) {
      _showSnackBar('Please enter your phone number');
      return;
    }

    if (!_isValidPhone(phone)) {
      _showSnackBar('Please enter a valid phone number (min 10 digits)');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter a password');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showSnackBar('Please confirm your password');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkPink,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 50),
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPhoneField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 20),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 40),
                    _buildSignUpButton(),
                    const SizedBox(height: 30),
                    _buildLoginLink(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //back button in App bar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10),
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkGrey, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'SIGN-UP',
      style: TextStyle(
        fontFamily: 'Gaqire',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
        letterSpacing: 3,
      ),
    );
  }

  //username input Field
  Widget _buildNameField() {
    return _buildInputField(
      label: 'Name',
      controller: _nameController,
      hintText: 'Emily',
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    );
  }

  //email input Field
  Widget _buildEmailField() {
    return _buildInputField(
      label: 'Email',
      controller: _emailController,
      hintText: 'emily@example.com',
      keyboardType: TextInputType.emailAddress,
    );
  }

  //Phone Number field
  Widget _buildPhoneField() {
    return _buildInputField(
      label: 'Phone',
      controller: _phoneController,
      hintText: '0000000000',
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget _buildPasswordField() {
    return _buildInputField(
      label: 'Password',
      controller: _passwordController,
      hintText: '••••••••',
      obscureText: !_isPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColors.mediumGrey,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    );
  }

  //confirm password
  Widget _buildConfirmPasswordField() {
    return _buildInputField(
      label: 'Confirm Password',
      controller: _confirmPasswordController,
      hintText: '••••••••',
      obscureText: !_isConfirmPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColors.mediumGrey,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGrey,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,

          //decoration
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            filled: true,
            fillColor: AppColors.white,

            //borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Sign-up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.burgundy,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
