import 'package:flutter/material.dart';
import '../model/order.dart' as farm_order;
import 'product_listing.dart';
import 'order_history.dart';
import '../user_taskbar.dart'; // Corrected import path for UserTaskbar

class OrderConfirmationScreen extends StatelessWidget {
  final farm_order.FarmOrder order;

  const OrderConfirmationScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Success Message
            Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Thank you for your order. We\'ll process it soon.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32),
            
            // Order Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Order Items
                    ...order.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
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
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
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
            
            SizedBox(height: 16),
            
            // Shipping Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.address,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Payment: ${order.paymentMethod}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Order Date: ${_formatDate(order.createdAt)}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListingPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Continue Shopping'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to UserTaskbar and select Orders tab
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserTaskbar(),
                          settings: RouteSettings(arguments: 3), // Orders tab index
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('View Orders'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 