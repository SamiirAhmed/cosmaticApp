import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/product_image.dart';
import '../../models/product.dart';
import 'add_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            expandedHeight: 120,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text("Product Catalog", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 60, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                final products = provider.allProducts;
                
                if (products.isEmpty) {
                   return const SliverFillRemaining(
                     child: Center(child: Text("No products found")),
                   );
                }

                return SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    int crossAxisCount = 1;
                    double childAspectRatio = 2.5; // for list view

                    if (width > 900) {
                      crossAxisCount = 4;
                      childAspectRatio = 0.75;
                    } else if (width > 600) {
                      crossAxisCount = 3;
                      childAspectRatio = 0.7;
                    } else if (width > 400) {
                      crossAxisCount = 2;
                      childAspectRatio = 0.65;
                    }

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCard(product: products[index], provider: provider);
                        },
                        childCount: products.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: childAspectRatio,
                      ),
                    );
                  },
                );
              },
            ),
          ),
           const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        backgroundColor: AppColors.primaryPeach,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final ProductProvider provider;
  
  const ProductCard({super.key, required this.product, required this.provider});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(_isHovered ? 0.2 : 0.05),
              blurRadius: _isHovered ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: _isHovered ? Border.all(color: AppColors.primaryGreen.withOpacity(0.5), width: 1.5) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      color: const Color(0xFFF5F7F5),
                      padding: const EdgeInsets.all(12),
                      child: Hero(
                        tag: 'product_${widget.product.id}',
                        child: ProductImage(imagePath: widget.product.imagePath, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: Text(
                        widget.product.category,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain, height: 1.2),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$${widget.product.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryPeach),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Stock: ${widget.product.quantity}",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _actionBtn(Icons.edit_rounded, Colors.grey[700]!, () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductScreen(product: widget.product),
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        _actionBtn(Icons.delete_outline_rounded, Colors.red[300]!, () {
                           widget.provider.deleteProduct(widget.product.id);
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
