import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/user.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../main/main_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Banner
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                'assets/images/cosmetics_banner.png',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Email Field
                  CustomTextField(
                    label: "Email",
                    hint: "Enter Your Email",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Field
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
                  
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter both email and password")),
                        );
                        return;
                      }

                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final result = await userProvider.login(email, password);

                      if (!context.mounted) return;

                      if (result['status'] == true) {
                        final user = userProvider.currentUser!;
                        final productProvider = Provider.of<ProductProvider>(context, listen: false);
                        await productProvider.fetchProducts(userId: user.id);
                        
                        if (user.role == UserRole.admin) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                        }
                      } else {
                        final message = result['message'] ?? "Invalid email or password. Please try again.";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
                    child: const Text("Log In"),
                  ),
                  
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "continue with",
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Go to Register Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppColors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Do Not Have An Account",
                      style: TextStyle(color: AppColors.textMain),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
