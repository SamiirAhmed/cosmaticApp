import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/product_image.dart';
import 'payments_screen.dart';
import '../main/main_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final cartItems = provider.cartItems;
          final productList = provider.allProducts;

          return Column(
            children: [
              const SizedBox(height: 50),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // If we are in the Tab view and can't pop, switch back to Home tab (index 0)
                          // However, the prompt specifically asks to go to "All Products" list page.
                          // Usually in a Bottom nav app, we'd want to switch tabs.
                          // But to be safe and avoid blank pages, we can push MainScreen.
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "my cart",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balanced spacing
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: cartItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Cart is empty", style: TextStyle(color: Colors.grey, fontSize: 18)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final productId = cartItems.keys.elementAt(index);
                          final quantity = cartItems.values.elementAt(index);
                          final product = provider.cartProductData[productId];

                          if (product == null) return const SizedBox();

                          return _buildCartItem(context, product, quantity, provider);
                        },
                      ),
              ),

              if (cartItems.isNotEmpty) _buildBottomSummary(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product, int quantity, ProductProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDE9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ProductImage(imagePath: product.imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        Text(
                          "Total: \$${(product.price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4B5E53)),
                        ),
                      ],
                    ),
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () => provider.updateQuantity(product.id, -1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              "$quantity",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildQtyBtn(
                            Icons.add, 
                            quantity < product.quantity ? () => provider.addToCart(product) : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Maximum stock reached"))
                              );
                            }, 
                            isAdd: true,
                            enabled: quantity < product.quantity,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => provider.removeFromCart(product.id),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, {bool isAdd = false, bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isAdd 
            ? (enabled ? const Color(0xFF4B5E53).withOpacity(0.1) : Colors.grey.withOpacity(0.1)) 
            : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: enabled ? (isAdd ? const Color(0xFF4B5E53) : Colors.grey.shade600) : Colors.grey.shade400),
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Total cost", provider.totalCost, isTotal: true),
          const SizedBox(height: 25),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaymentsScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF4B5E53),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Make payment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            "\$${value.abs().toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
