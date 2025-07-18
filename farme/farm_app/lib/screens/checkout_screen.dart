import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../authContext.dart';
import '../model/order.dart' as farm_order;
import 'order_confirmation.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPaymentMethod = 'Cash on Delivery';
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Credit Card',
    'Mobile Money',
  ];

  int _selectedCardIndex = 0;
  final List<Map<String, dynamic>> _cards = [
    {
      'type': 'Mastercard',
      'icon': Icons.credit_card,
      'bgColor': Color(0xFF232323),
      'logo': 'assets/mastercard.png', // Replace with your asset path
      'number': '1234 1234 1234 1234',
      'name': 'Jane Doe',
      'expiry': '12/28',
    },
    {
      'type': 'Visa',
      'icon': Icons.credit_card,
      'bgColor': Color(0xFF1A237E),
      'logo': 'assets/visa.png', // Replace with your asset path
      'number': '4321 4321 4321 4321',
      'name': 'Jane Doe',
      'expiry': '11/27',
    },
    {
      'type': 'Mobile Money',
      'icon': Icons.phone_android,
      'bgColor': Color(0xFF388E3C),
      'logo': 'assets/mobile_money.png',
      'number': '',
      'name': '',
      'expiry': '',
    },
  ];
  final TextEditingController _cardNameController = TextEditingController(text: 'Jane Doe');
  final TextEditingController _cvvController = TextEditingController(text: '123');
  final TextEditingController _cardNumberController = TextEditingController(text: '1234 **** **** ****');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ...cartProvider.items.map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name} (x${item.quantity})',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${cartProvider.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Shipping Information
                  Text(
                    'Shipping Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your delivery address';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Payment Method
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._paymentMethods.map((method) => RadioListTile<String>(
                    title: Text(method),
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                  )),
                  SizedBox(height: 18),
                  if (_selectedPaymentMethod == 'Mobile Money') ...[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Mobile Money Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ] else if (_selectedPaymentMethod == 'Credit Card') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cardNameController,
                            decoration: InputDecoration(
                              labelText: 'Cardholder Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  SizedBox(height: 18),
                  // Remove the Save button (the ElevatedButton with child: Text('Save'))
                  
                  SizedBox(height: 32),
                  
                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isProcessing
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Place Order',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final cartProvider = context.read<CartProvider>();
      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<OrderProvider>();

      final order = farm_order.FarmOrder(
        id: '', // Will be set by Firestore
        userId: authProvider.user!.uid,
        items: cartProvider.items,
        total: cartProvider.total,
        status: 'Pending',
        address: _addressController.text,
        paymentMethod: _selectedPaymentMethod,
        createdAt: DateTime.now(),
      );

      await orderProvider.createOrder(order);
      
      // Clear cart after successful order
      cartProvider.clear();

      // Navigate to order confirmation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
} 