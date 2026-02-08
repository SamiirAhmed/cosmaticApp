import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';

import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Not used in backend yet, but keep
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Register",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const Text(
                "Create your new account",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Name Field
              CustomTextField(
                label: "Full Name",
                hint: "Enter Your Name",
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: "Phone",
                hint: "Enter Your Phone Number",
                controller: _phoneController,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: "Email",
                hint: "Enter Your Email",
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: "Password",
                hint: "Enter Your Password",
                controller: _passwordController,
                isPassword: _obscurePassword,
                suffixIcon: _obscurePassword 
                    ? Icons.visibility_off_outlined 
                    : Icons.visibility_outlined,
                onSuffixIconPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: "Confirm Password",
                hint: "Re-enter Your Password",
                controller: _confirmPasswordController,
                isPassword: _obscureConfirmPassword,
                suffixIcon: _obscureConfirmPassword 
                    ? Icons.visibility_off_outlined 
                    : Icons.visibility_outlined,
                onSuffixIconPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              const Text.rich(
                TextSpan(
                  text: "By signing up you agree to our ",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: "Terms & Conditions",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  final confirm = _confirmPasswordController.text.trim();

                  if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields are required")));
                    return;
                  }

                  if (password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                    return;
                  }

                  final result = await Provider.of<UserProvider>(context, listen: false)
                      .register(name, email, password, phone: _phoneController.text.trim());

                  if (!context.mounted) return;

                  if (result['status'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful! Please Login.")));
                    Navigator.pop(context);
                  } else {
                    final message = result['message'] ?? "Registration Failed. Try again.";
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
