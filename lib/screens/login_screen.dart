import 'package:flutter/material.dart';
import 'package:she_bloom/constants/colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //validation
  void _handleLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('Please Enter Your Username');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please Enter Your Password');
      return;
    }

    print('Username: $username');
    print('Password: $password');
    _showSnackBar('Login functionality coming soon!');
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

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 50),
                _buildUsernameField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 40),
                _buildLoginButton(),
                const SizedBox(height: 30),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //LOGIN header
  Widget _buildHeader() {
    return Text(
      'LOGIN',
      style: TextStyle(
        fontFamily: 'Gaqire',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
        letterSpacing: 3,
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGrey,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Enter username',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  //password input field
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible, // Hide password
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
          ),
        ),
      ],
    );
  }

  // LogIn button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Login',
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

  // Don't have account, SignUp link
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGrey,
          ),
        ),
        GestureDetector(
          onTap: _navigateToSignUp,
          child: Text(
            'Sign-up',
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
