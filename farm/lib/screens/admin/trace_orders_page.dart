import 'package:flutter/material.dart';

class TraceOrdersPage extends StatelessWidget {
  const TraceOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'id': 'ORD001',
        'user': 'Daniel',
        'total': 25.50,
        'status': 'Paid',
      },
      {
        'id': 'ORD002',
        'user': 'Ama',
        'total': 15.00,
        'status': 'Pending',
      },
      {
        'id': 'ORD003',
        'user': 'Kwame',
        'total': 40.00,
        'status': 'Failed',
      },
    ];
    Color getStatusColor(String status) {
      switch (status) {
        case 'Paid':
          return Colors.green;
        case 'Pending':
          return Colors.orange;
        case 'Failed':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Trace Orders'), backgroundColor: Colors.green),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getStatusColor(order['status'].toString()),
                child: Text(order['status'].toString()[0]),
              ),
              title: Text('Order #${order['id'].toString()}'),
              subtitle: Text('User: ${order['user'].toString()}\nTotal: ₵${order['total']}'),
              trailing: Text(order['status'].toString(), style: TextStyle(color: getStatusColor(order['status'].toString()), fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
} 