import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../model/category.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AdminCategoryManagement extends StatefulWidget {
  @override
  _AdminCategoryManagementState createState() => _AdminCategoryManagementState();
}

class _AdminCategoryManagementState extends State<AdminCategoryManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  
  bool _isEditing = false;
  String? _editingCategoryId;
  String _selectedIconUrl = '';
  bool _isActive = true;
  bool _isSaving = false;
  File? _pickedImageFile;

  final List<String> _defaultIcons = [
    'lib/asset/11473559.png',
    'lib/asset/1247d03d-2cc4-4e55-8420-6fe754a95d77.jpg',
    'lib/asset/fd90aad7-5a1a-4d47-b6cb-6c6a6dfc6842.jpg',
    'lib/asset/letter-f_8057804.png',
    'lib/asset/food_11034759.png',
    'lib/asset/google_720255.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _colorController.clear();
    _selectedIconUrl = '';
    _isActive = true;
    _isEditing = false;
    _editingCategoryId = null;
    _pickedImageFile = null;
  }

  void _editCategory(Category category) {
    setState(() {
      _isEditing = true;
      _editingCategoryId = category.id;
      _nameController.text = category.name;
      _descriptionController.text = category.description;
      _colorController.text = category.color;
      _selectedIconUrl = category.iconUrl;
      _isActive = category.isActive;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_pickedImageFile == null) return _selectedIconUrl;
    
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('category_icons')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final uploadTask = storageRef.putFile(_pickedImageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return _selectedIconUrl;
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final iconUrl = await _uploadImage();
      
      final category = Category(
        id: _editingCategoryId ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconUrl: iconUrl,
        color: _colorController.text.trim(),
        isActive: _isActive,
        createdAt: _isEditing ? DateTime.now() : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final categoryProvider = context.read<CategoryProvider>();
      
      if (_isEditing) {
        await categoryProvider.updateCategory(category);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully!')),
        );
      } else {
        await categoryProvider.addCategory(category);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully!')),
        );
      }

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCategory(String categoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete this category? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<CategoryProvider>().deleteCategory(categoryId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Category Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _resetForm,
            tooltip: 'Add New Category',
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Form Section
              if (!_isEditing && _nameController.text.isEmpty) ...[
                _buildAddCategoryForm(),
              ] else ...[
                _buildEditCategoryForm(),
              ],
              
              // Categories List
              Expanded(
                child: _buildCategoriesList(categoryProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddCategoryForm() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildCategoryForm(),
        ],
      ),
    );
  }

  Widget _buildEditCategoryForm() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: _resetForm,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildCategoryForm(),
        ],
      ),
    );
  }

  Widget _buildCategoryForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter category name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Color Field
          TextFormField(
            controller: _colorController,
            decoration: InputDecoration(
              labelText: 'Color (Hex Code)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(Icons.color_lens),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter color code';
              }
              if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value.trim())) {
                return 'Please enter valid hex color code (e.g., #FF6B6B)';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Icon Selection
          Text(
            'Select Icon:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ..._defaultIcons.map((icon) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIconUrl = icon;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedIconUrl == icon ? Colors.green : Colors.grey.shade300,
                      width: _selectedIconUrl == icon ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      icon,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image),
                    ),
                  ),
                ),
              )),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _pickedImageFile != null ? Colors.green : Colors.grey.shade300,
                      width: _pickedImageFile != null ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(_pickedImageFile!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.add_photo_alternate, color: Colors.grey),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Active Toggle
          Row(
            children: [
              Checkbox(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value ?? true;
                  });
                },
              ),
              Text('Active'),
            ],
          ),
          SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isEditing ? 'Update Category' : 'Add Category'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(CategoryProvider categoryProvider) {
    if (categoryProvider.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first category to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: categoryProvider.categories.length,
      itemBuilder: (context, index) {
        final category = categoryProvider.categories[index];
        return _CategoryCard(
          category: category,
          onEdit: () => _editCategory(category),
          onDelete: () => _deleteCategory(category.id),
          onToggleStatus: () => categoryProvider.toggleCategoryStatus(category.id),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
          ),
          child: category.iconUrl.startsWith('lib/asset/')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    category.iconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.category, color: Colors.white),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    category.iconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.category, color: Colors.white),
                  ),
                ),
        ),
        title: Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.description),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: category.isActive ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${category.productCount} products',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(category.isActive ? Icons.visibility_off : Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text(category.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'toggle':
                onToggleStatus();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
      ),
    );
  }
}
