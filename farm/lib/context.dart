import 'package:flutter/material.dart';

// 1. Product Model
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.description = 'A detailed description of the product.',
  });
}

// lib/models/cart_item.dart (NEW: CartItem Model)
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Method to get total price for this item
  double get totalPrice => product.price * quantity;
}

// lib/services/auth_service.dart (Existing AuthService - no changes needed for this feature)
class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false; // Initial state: not logged in

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    notifyListeners();
  }
}

// lib/services/cart_service.dart (NEW: CartService for managing shopping cart)
class CartService extends ChangeNotifier {
  // Using a Map for efficient access and update by product ID
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items}; // Return a copy to prevent external modification

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existingItem) {
        existingItem.quantity += 1;
        return existingItem;
      });
    } else {
      _items.putIfAbsent(
          product.id, () => CartItem(product: product, quantity: 1));
    }
    notifyListeners(); // Notify listeners that the cart has changed
  }

  void removeItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(productId, (existingItem) {
        existingItem.quantity -= 1;
        return existingItem;
      });
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void deleteItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}