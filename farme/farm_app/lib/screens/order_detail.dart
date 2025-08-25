import 'package:flutter/material.dart';
import '../model/order.dart' as farm_order;

class OrderDetailScreen extends StatelessWidget {
  final farm_order.FarmOrder order;
  final bool isAdmin;

  const OrderDetailScreen({Key? key, required this.order, this.isAdmin = false}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(_formatDate(order.createdAt), style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Items
          Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...order.items.map((item) => Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.product.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : Icon(Icons.image, color: Colors.grey),
                ),
                SizedBox(height: 8, width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
                Text('₵${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
          )),

          SizedBox(height: 16),

          // Shipping / Payment
          Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _summaryRow('Address', order.address),
          _summaryRow('Payment', order.paymentMethod),
          if (isAdmin) _summaryRow('User', order.userId),

          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₵${order.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
