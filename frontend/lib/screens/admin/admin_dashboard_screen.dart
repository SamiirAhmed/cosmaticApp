import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'user_management_screen.dart';
import 'product_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminStats();
  }

  Future<void> _fetchAdminStats() async {
    setState(() => _isLoadingStats = true);
    
    try {
      final response = await ApiService.get('admin/stats');
      
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _totalRevenue = (response['data']['total_revenue'] ?? 0).toDouble();
          _totalOrders = response['data']['total_orders'] ?? 0;
          _isLoadingStats = false;
        });
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          // Premium Header with Gradient
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreen, Color(0xFF2D3C32)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 80.0, 25.0, 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.primaryPeach,
                                radius: 25,
                                child: Text("A", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  Text(userProvider.currentUser?.name ?? "Admin", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "Store Performance Dashboard",
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  // Clear authentication data
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  userProvider.logout();
                  
                  // Navigate to login and clear navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Analytics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 20),

                  // Analytics Grid
                  Row(
                    children: [
                      _buildEnhancedStatCard(
                        "Products",
                        productProvider.allProducts.length.toString(),
                        Icons.inventory_2_rounded,
                        AppColors.primaryGreen,
                        false,
                      ),
                      const SizedBox(width: 15),
                      _buildEnhancedStatCard(
                        "Total Users",
                        userProvider.users.length.toString(),
                        Icons.group_rounded,
                        AppColors.primaryPeach,
                        false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildEnhancedStatCard(
                        "Orders",
                        _totalOrders.toString(),
                        Icons.shopping_bag_rounded,
                        AppColors.primaryPeach,
                        _isLoadingStats,
                      ),
                      const SizedBox(width: 15),
                      _buildEnhancedStatCard(
                        "Revenue",
                        "\$${_totalRevenue.toStringAsFixed(2)}",
                        Icons.payments_rounded,
                        AppColors.primaryGreen,
                        _isLoadingStats,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  const Text(
                    "Management Console",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 20),

                  _buildPremiumActionTile(
                    context,
                    "User Management",
                    "Security, roles & access control",
                    Icons.security_rounded,
                    AppColors.primaryGreen,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen())),
                  ),
                  _buildPremiumActionTile(
                    context,
                    "Product Catalog",
                    "Add, update or remove items",
                    Icons.inventory_2_rounded,
                    AppColors.primaryPeach,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagementScreen())),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color, bool isLoading) {
    return Expanded(
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Icon(Icons.trending_up_rounded, color: Colors.green.withOpacity(0.4), size: 16),
                ],
              ),
              const Spacer(),
              isLoading 
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color)),
                  )
                : Text(value, 
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textMain,
                      height: 1.0,
                    )
                  ),
              const SizedBox(height: 4),
              Text(title, 
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
