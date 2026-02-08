import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order.dart';
import 'order_success_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedMethod = "EVC Plus (Hormuud)";

  final List<Map<String, String>> paymentMethods = [
    {
      "name": "EVC Plus (Hormuud)",
      "logo": "assets/images/hormuud_logo.png",
    },
    {
      "name": "e-Dahab (Somtel)",
      "logo": "assets/images/somtel_logo.png",
    },
    {
      "name": "Premier Bank",
      "logo": "assets/images/somtel_logo.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black54),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Payments",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Payment Options List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return _buildPaymentCard(method, productProvider.totalCost);
              },
            ),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: GestureDetector(
              onTap: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please login to complete purchase"))
                    );
                    return;
                }

                // 1. Prepare Order items
                List<OrderItem> orderItems = [];
                productProvider.cartItems.forEach((productId, quantity) {
                  try {
                    final product = productProvider.allProducts.firstWhere((p) => p.id == productId);
                    orderItems.add(OrderItem(product: product, quantity: quantity));
                  } catch (e) {
                    // product might be filtered out or deleted
                  }
                });

                // 2. Add to History
                if (orderItems.isNotEmpty) {
                  final userId = userProvider.currentUser?.id ?? '1'; // Fallback to '1' if currentUser or its ID is null
                  final success = await orderProvider.addOrder(
                      orderItems,
                      productProvider.totalCost,
                      userId
                  );
                  
                  if (success) {
                     // 3. Clear Cart
                    productProvider.clearCart();

                    // 4. Navigate to success
                    if (context.mounted) {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                        );
                    }
                  } else {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to place order. Try again."))
                        );
                     }
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B5E53),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Text(
                  "Confirm Payment",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, String> method, double totalAmount) {
    bool isSelected = selectedMethod == method['name'];

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method['name']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Logo Placeholder (Simplified as colored box for now until real assets)
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: method['name']!.contains("Hormuud") || method['name']!.contains("EVC") ? Colors.white : const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(
                child: method['name']!.contains("Hormuud") || method['name']!.contains("EVC")
                    ? const Icon(Icons.wifi, color: Colors.green, size: 30) // EVC Plus Mock
                    : const Icon(Icons.flash_on, color: Colors.blue, size: 30), // Somtel/Bank Mock
              ),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "\$${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            // Selection Circle
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.red : Colors.grey.shade300,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  if (isSelected)
                    const BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
