import 'package:flutter/material.dart';
import 'checkout_page.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': '001', 'item': 'Tomatoes', 'qty': 10, 'status': 'Delivered'},
      {'id': '002', 'item': 'Corn', 'qty': 5, 'status': 'Pending'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(order['item'].toString()[0]),
              ),
              title: Text(order['item'].toString()),
              subtitle: Text('Qty: ${order['qty'].toString()} | Status: ${order['status'].toString()}'),
              trailing: IconButton(
                icon: const Icon(Icons.payment, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutPage()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
} 