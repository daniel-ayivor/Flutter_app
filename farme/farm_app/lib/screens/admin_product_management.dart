import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../model/product.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AdminProductManagement extends StatefulWidget {
  @override
  _AdminProductManagementState createState() => _AdminProductManagementState();
}

class _AdminProductManagementState extends State<AdminProductManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController();
  String _selectedCategory = 'Fruits';
  String _imageUrl = '';
  bool _isEditing = false;
  String? _editingProductId;
  File? _pickedImageFile;
  bool _isSaving = false;

  final List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Grains',
    'Livestock',
    'Equipment',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management', style: TextStyle(fontSize: 16.0),),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${productProvider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.fetchProducts(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return AdminProductCard(
                product: product,
                onEdit: () => _editProduct(product),
                onDelete: () => _deleteProduct(product.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDialog() {
    _resetForm();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              title: Text(
                _isEditing ? 'Edit Product' : 'Add Product',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setDialogState) => Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image with tap-to-preview
                      InkWell(
                        onTap: (_pickedImageFile != null || _imageUrl.isNotEmpty)
                            ? _openImagePreview
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: _pickedImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _pickedImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (_imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.image, color: Colors.grey, size: 64);
                                        },
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt, color: Colors.grey.shade400, size: 64),
                                        SizedBox(height: 16),
                                        Text(
                                          'TAKE PHOTO OR UPLOAD',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Maximum upto 5 Images',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImageDialog(setDialogState),
                            icon: Icon(Icons.photo_library),
                            label: Text('Pick Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Product Name
                      Text(
                        'PRODUCT NAME',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter product name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Price
                      Text(
                        'PRICE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₵', style: TextStyle(fontWeight: FontWeight.bold)),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Category
                      Text(
                        'CATEGORY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Rating
                      Text(
                        'RATING',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _ratingController,
                        decoration: InputDecoration(
                          hintText: '0-5',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rating';
                          }
                          final rating = double.tryParse(value);
                          if (rating == null || rating < 0 || rating > 5) {
                            return 'Please enter a valid rating (0-5)';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Description
                      Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter product description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () => _saveProduct(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isEditing ? 'UPDATE PRODUCT' : 'ADD PRODUCT'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editProduct(Product product) {
    _isEditing = true;
    _editingProductId = product.id;
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _descriptionController.text = product.description;
    _ratingController.text = product.rating.toString();
    _selectedCategory = product.category;
    _imageUrl = product.imageUrl;
    _showProductDialog();
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(productId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<String> _uploadImage(File file) async {
    final storage = FirebaseStorage.instance;
    final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = storage.ref().child('products').child(fileName);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    try {
      String imageUrl = _imageUrl;
      if (_pickedImageFile != null) {
        imageUrl = await _uploadImage(_pickedImageFile!);
      }

      final product = Product(
        id: _editingProductId ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        rating: double.parse(_ratingController.text),
        category: _selectedCategory,
        imageUrl: imageUrl,
      );

      if (_isEditing) {
        await context.read<ProductProvider>().updateProduct(product);
      } else {
        await context.read<ProductProvider>().addProduct(product);
      }
      
      if (!mounted) return;
      
      // Close the dialog first
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Product updated successfully!' : 'Product added successfully!'),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Reset form for next use
      _resetForm();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetForm() {
    _isEditing = false;
    _editingProductId = null;
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _ratingController.clear();
    _selectedCategory = 'Fruits';
    _imageUrl = '';
    _pickedImageFile = null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
        _imageUrl = '';
      });
    }
  }

  Future<void> _pickImageDialog(void Function(void Function()) setStateDialog) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Update both dialog state and outer state so preview updates immediately
      setStateDialog(() {});
      if (mounted) {
        setState(() {
          _pickedImageFile = File(pickedFile.path);
          _imageUrl = '';
        });
      }
    }
  }

  void _openImagePreview() {
    final imageWidget = _pickedImageFile != null
        ? Image.file(_pickedImageFile!, fit: BoxFit.contain)
        : (_imageUrl.isNotEmpty
            ? Image.network(_imageUrl, fit: BoxFit.contain)
            : null);
    if (imageWidget == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: imageWidget,
            ),
          ),
        ),
      ),
    );
  }
}

class AdminProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: Colors.grey, size: 32);
                        },
                      ),
                    )
                  : Icon(Icons.image, color: Colors.grey, size: 32),
            ),
            
            SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 6),
                  
                  Text(
                    '₵${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Icons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit Icon
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
                
                // Delete Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 