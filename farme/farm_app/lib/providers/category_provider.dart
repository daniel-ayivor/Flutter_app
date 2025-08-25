import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/category.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Category> get activeCategories => _categories.where((c) => c.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get category names for dropdowns
  List<String> get categoryNames => ['All', ..._categories.map((c) => c.name)];

  // Get category by name
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore.collection('categories').orderBy('createdAt', descending: false).get();
      _categories = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final docRef = await _firestore.collection('categories').add(category.toMap());
      final newCategory = category.copyWith(id: docRef.id);
      _categories.add(newCategory);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error adding category: $e');
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore.collection('categories').doc(category.id).update(category.toMap());
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating category: $e');
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      // Check if category has products
      final productsSnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: getCategoryById(categoryId)?.name)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        _error = 'Cannot delete category with existing products';
        notifyListeners();
        return;
      }

      await _firestore.collection('categories').doc(categoryId).delete();
      _categories.removeWhere((c) => c.id == categoryId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error deleting category: $e');
      notifyListeners();
    }
  }

  Future<void> toggleCategoryStatus(String categoryId) async {
    try {
      final category = getCategoryById(categoryId);
      if (category != null) {
        final updatedCategory = category.copyWith(
          isActive: !category.isActive,
          updatedAt: DateTime.now(),
        );
        await updateCategory(updatedCategory);
      }
    } catch (e) {
      _error = e.toString();
      print('Error toggling category status: $e');
      notifyListeners();
    }
  }

  Future<void> updateProductCount(String categoryName) async {
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: categoryName)
          .get();

      final category = getCategoryByName(categoryName);
      if (category != null) {
        final updatedCategory = category.copyWith(
          productCount: productsSnapshot.docs.length,
          updatedAt: DateTime.now(),
        );
        await updateCategory(updatedCategory);
      }
    } catch (e) {
      print('Error updating product count: $e');
    }
  }

  // Initialize with default categories if none exist
  Future<void> initializeDefaultCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      if (snapshot.docs.isEmpty) {
        final defaultCategories = [
          Category(
            id: '',
            name: 'Fruits',
            description: 'Fresh fruits and berries',
            iconUrl: 'lib/asset/11473559.png',
            color: '#FF6B6B',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: '',
            name: 'Vegetables',
            description: 'Fresh vegetables and greens',
            iconUrl: 'lib/asset/1247d03d-2cc4-4e55-8420-6fe754a95d77.jpg',
            color: '#4ECDC4',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: '',
            name: 'Grains and Cereal',
            description: 'Grains, cereals, and legumes',
            iconUrl: 'lib/asset/fd90aad7-5a1a-4d47-b6cb-6c6a6dfc6842.jpg',
            color: '#45B7D1',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: '',
            name: 'Livestock',
            description: 'Farm animals and livestock products',
            iconUrl: 'lib/asset/letter-f_8057804.png',
            color: '#96CEB4',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: '',
            name: 'Seeds or Seedlings',
            description: 'Plant seeds and young plants',
            iconUrl: 'lib/asset/food_11034759.png',
            color: '#FFEAA7',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: '',
            name: 'Equipment',
            description: 'Farming tools and equipment',
            iconUrl: 'lib/asset/google_720255.png',
            color: '#DDA0DD',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final category in defaultCategories) {
          await addCategory(category);
        }
      }
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
