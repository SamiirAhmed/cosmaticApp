import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/product_image.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _quantityController;
  late String _selectedCategory;
  
  XFile? _pickedFile;
  Uint8List? _webImageBytes;
  bool _isUrlMode = false;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? "");
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? "");
    _imageUrlController = TextEditingController(text: widget.product?.imagePath.startsWith('http') == true ? widget.product?.imagePath : "");
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? "0");
    _selectedCategory = widget.product?.category ?? 'skin care';
    
    if (widget.product != null && widget.product!.imagePath.startsWith('http')) {
      _isUrlMode = true;
    }
  }

  final List<String> _categories = [
    'skin care', 'hair cut', 'face wash', 'make up', 'salon'
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedFile = image;
        _webImageBytes = bytes;
        _isUrlMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(isEditing ? "Edit Product" : "Add New Product", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(isEditing ? "Update Product Details" : "New Inventory Details", 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(height: 30),
                  
                  // Image Selection Section
                  _buildLabel("Product Image"),
                  const SizedBox(height: 15),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: _isUrlMode
                            ? (_imageUrlController.text.isNotEmpty 
                                ? ProductImage(imagePath: _imageUrlController.text, fit: BoxFit.contain)
                                : const Icon(Icons.link_rounded, size: 50, color: Colors.grey))
                            : (_webImageBytes != null 
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(_webImageBytes!, fit: BoxFit.contain),
                                  )
                                : (widget.product != null 
                                    ? ProductImage(imagePath: widget.product!.imagePath, fit: BoxFit.contain)
                                    : const Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.grey))),
                        ),
                        Positioned(
                          right: 15,
                          bottom: 15,
                          child: Row(
                            children: [
                              _imageActionBtn(
                                icon: Icons.upload_file_rounded,
                                label: "Upload",
                                active: !_isUrlMode,
                                onTap: () {
                                  setState(() => _isUrlMode = false);
                                  _pickImage();
                                }
                              ),
                              const SizedBox(width: 10),
                              _imageActionBtn(
                                icon: Icons.link_rounded,
                                label: "URL",
                                active: _isUrlMode,
                                onTap: () => setState(() => _isUrlMode = true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_isUrlMode) ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: _imageUrlController,
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Paste image URL here...",
                        prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primaryPeach),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  
                  _buildLabel("Product Title"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "e.g. Organic Face Wash",
                      prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primaryGreen),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Price (\$)"),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "0.00",
                                prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primaryGreen),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Category"),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              items: _categories.map((cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val!),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  _buildLabel("Available Stock"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "0",
                      prefixIcon: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryGreen),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 60),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () async {
                        if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                          setState(() => _isSubmitting = true);
                          
                          String finalPath = widget.product?.imagePath ?? 'assets/images/product1.png';
                          
                          if (_isUrlMode && _imageUrlController.text.isNotEmpty) {
                            finalPath = _imageUrlController.text;
                          } else if (!_isUrlMode && _pickedFile != null) {
                            finalPath = _pickedFile!.path;
                          }

                          bool success;
                          if (isEditing) {
                            final updatedProduct = Product(
                              id: widget.product!.id,
                              name: _nameController.text,
                              category: _selectedCategory,
                              price: double.parse(_priceController.text),
                              imagePath: finalPath,
                              quantity: int.parse(_quantityController.text),
                              isFavorite: widget.product!.isFavorite,
                            );
                            success = await Provider.of<ProductProvider>(context, listen: false).updateProduct(updatedProduct, _pickedFile);
                          } else {
                            final newProduct = Product(
                              id: DateTime.now().toString(),
                              name: _nameController.text,
                              category: _selectedCategory,
                              price: double.parse(_priceController.text),
                              imagePath: finalPath,
                              quantity: int.parse(_quantityController.text),
                            );
                            success = await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct, _pickedFile);
                          }
                          
                          setState(() => _isSubmitting = false);

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success!"), backgroundColor: Colors.green));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action failed. Check logs."), backgroundColor: Colors.red));
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditing ? "CONFIRM CHANGES" : "ADD TO STORE", 
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageActionBtn({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGreen),
          boxShadow: active ? [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.primaryGreen),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: active ? Colors.white : AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(text, 
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain, letterSpacing: 0.5)),
    );
  }
}
