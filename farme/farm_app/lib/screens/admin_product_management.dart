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
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        content: SizedBox(
          width: 400, // Increased width
          child: StatefulBuilder(
            builder: (context, setStateDialog) => SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image with tap-to-preview
                  InkWell(
                    onTap: (_pickedImageFile != null || _imageUrl.isNotEmpty)
                        ? _openImagePreview
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _pickedImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _pickedImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (_imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.image, color: Colors.grey);
                                    },
                                  ),
                                )
                              : Icon(Icons.image, color: Colors.grey)),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _pickImageDialog(setStateDialog),
                        child: Text('Pick Image'),
                      ),
                      if (_pickedImageFile != null || _imageUrl.isNotEmpty) ...[
                        SizedBox(width: 12),
                        TextButton(
                          onPressed: _openImagePreview,
                          child: Text('Preview'),
                        ),
                      ],
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Product Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '₵',
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
                  
                  SizedBox(height: 16),
                  
                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
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
                  
                  SizedBox(height: 16),
                  
                  // Rating
                  TextFormField(
                    controller: _ratingController,
                    decoration: InputDecoration(
                      labelText: 'Rating (0-5)',
                      border: OutlineInputBorder(),
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
                  
                  SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : () => _saveProduct(),
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_isEditing ? 'Update' : 'Add'),
          ),
        ],
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

    try {
      if (_isEditing) {
        await context.read<ProductProvider>().updateProduct(product);
      } else {
        await context.read<ProductProvider>().addProduct(product);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Product updated' : 'Product added')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e'), backgroundColor: Colors.red),
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
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: Colors.grey);
                        },
                      ),
                    )
                  : Icon(Icons.image, color: Colors.grey),
            ),
            SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₵${product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 2),
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 