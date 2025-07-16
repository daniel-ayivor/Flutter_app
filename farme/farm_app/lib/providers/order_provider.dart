import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order.dart' as farm_order;
import '../model/cart_item.dart';
import '../model/product.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<farm_order.FarmOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<farm_order.FarmOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserOrders(String userId) async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return farm_order.FarmOrder(
          id: doc.id,
          userId: data['userId'] ?? '',
          items: (data['items'] is List
              ? (data['items'] as List)
              : <dynamic>[]) // fallback to empty list
            .where((item) => item != null && item['product'] != null)
            .map((item) => CartItem(
                  product: Product.fromMap(item['product']),
                  quantity: item['quantity'] ?? 1,
                ))
            .toList(),
          total: (data['total'] ?? 0).toDouble(),
          status: data['status'] ?? 'Unknown',
          address: data['address'] ?? '',
          paymentMethod: data['paymentMethod'] ?? '',
          createdAt: (data['createdAt'] is Timestamp)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllOrders() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      
      _orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return farm_order.FarmOrder(
          id: doc.id,
          userId: data['userId'] ?? '',
          items: (data['items'] is List
              ? (data['items'] as List)
              : <dynamic>[]) // fallback to empty list
            .where((item) => item != null && item['product'] != null)
            .map((item) => CartItem(
                  product: Product.fromMap(item['product']),
                  quantity: item['quantity'] ?? 1,
                ))
            .toList(),
          total: (data['total'] ?? 0).toDouble(),
          status: data['status'] ?? 'Unknown',
          address: data['address'] ?? '',
          paymentMethod: data['paymentMethod'] ?? '',
          createdAt: (data['createdAt'] is Timestamp)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrder(farm_order.FarmOrder order) async {
    try {
      await _firestore.collection('orders').add({
        'userId': order.userId,
        'items': order.items.map((item) => {
          'product': item.product.toMap(),
          'quantity': item.quantity,
        }).toList(),
        'total': order.total,
        'status': order.status,
        'address': order.address,
        'paymentMethod': order.paymentMethod,
        'createdAt': Timestamp.fromDate(order.createdAt),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
      await fetchAllOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 