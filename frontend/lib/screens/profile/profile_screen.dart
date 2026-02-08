import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../product/order_history_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF9FBF9),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Premium Dynamic Header
                _buildHeader(context, user?.name ?? "Guest User", user?.email ?? ""),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Personal Information"),
                      const SizedBox(height: 15),
                      _buildInfoTile(Icons.person_outline_rounded, "Name", user?.name ?? "Guest"),
                      _buildInfoTile(Icons.email_outlined, "Email", user?.email ?? "No Email"),
                      
                      const SizedBox(height: 30),

                      _buildSectionTitle("My Activity"),
                      const SizedBox(height: 15),

                      _buildProfileMenu(
                        icon: Icons.shopping_bag_outlined,
                        title: "Order History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      // Styled Logout Button
                      _buildLogoutButton(context, userProvider),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email) {
    String initial = (name.isNotEmpty) ? name[0].toUpperCase() : "?";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40, left: 30, right: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryPeach,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(name, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(email, 
            style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
    );
  }

  Widget _buildProfileMenu({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primaryGreen, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primaryGreen, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain, fontSize: 16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: () {
          provider.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text("SIGN OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
