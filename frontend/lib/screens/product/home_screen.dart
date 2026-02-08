import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../providers/user_provider.dart';
import '../../widgets/product_image.dart';
import 'product_detail_screen.dart';
import 'products_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final isDashboard = provider.selectedCategory == 'All';

        return Scaffold(
          backgroundColor: Colors.white,
          body: isDashboard ? _buildDashboard(context, provider) : _buildCategoryView(context, provider),
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context, ProductProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildCategoryList(),
                const SizedBox(height: 30),
                _buildSectionTitle("Recommended For You", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductsListScreen()),
                  );
                }),
                const SizedBox(height: 15),
                _buildProductGrid(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryView(BuildContext context, ProductProvider provider) {
    final catName = provider.selectedCategory;
    final products = provider.products;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => provider.setCategory('All'),
              ),
            ],
          ),
          Center(
            child: Text(
              catName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        const Text(
                          "No products found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 25,
                    ),
                    itemBuilder: (context, index) => _buildProductCard(context, products[index], provider, index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "Samiir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_basket_outlined, color: Colors.greenAccent),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Consumer<ProductProvider>(
                    builder: (context, provider, child) {
                      return TextField(
                        onChanged: (value) => provider.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: "search",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: provider.searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    provider.setSearchQuery('');
                                    // Optionally clear controller if added
                                  },
                                  child: const Icon(Icons.close, color: Colors.grey),
                                )
                              : const Icon(Icons.tune, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.tune, color: AppColors.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text("See all", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }


  Widget _buildCategoryList() {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view},
      {'name': 'skin care', 'icon': Icons.opacity},
      {'name': 'hair cut', 'icon': Icons.content_cut},
      {'name': 'face wash', 'icon': Icons.face},
      {'name': 'make up', 'icon': Icons.brush},
      {'name': 'salon', 'icon': Icons.chair},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                final isSelected = provider.selectedCategory == cat['name'];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        provider.setCategory(cat['name'] as String);
                        provider.fetchProducts(userId: userProvider.currentUser?.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primaryGreen 
                              : Colors.grey.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'] as IconData, 
                          color: isSelected ? Colors.white : AppColors.primaryGreen, 
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['name'] as String,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider provider) {
    final products = provider.products.take(2).toList();
    if (products.isEmpty) {
      return const Center(child: Text("No products found in this category"));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product, provider, index);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, ProductProvider provider, int index) {
    // Alternating colors in detail view: Light Peach and Dark Forest Green
    final Color bgColor = index % 4 == 0 || index % 4 == 2
        ? const Color(0xFFFDF1E6)
        : const Color(0xFF637D6E);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: ProductImage(imagePath: product.imagePath, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          onPressed: () {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            if (userProvider.currentUser != null) {
                              provider.toggleFavorite(product.id, userProvider.currentUser!.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please login to set favorites"))
                              );
                            }
                          },
                          icon: Icon(
                            product.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: product.isFavorite ? Colors.redAccent : const Color(0xFFFFD700),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            product.quantity > 0 ? "In Stock: ${product.quantity}" : "Out of Stock",
            style: TextStyle(
              fontSize: 12,
              color: product.quantity > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
