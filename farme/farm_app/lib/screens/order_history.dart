import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../authContext.dart';
import '../model/order.dart' as farm_order;

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  OrderHistoryScreenState createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<OrderProvider>().fetchUserOrders(authProvider.user!.uid);
      }
    });
  }

  Future<void> _refreshOrders() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<OrderProvider>().fetchUserOrders(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              // Show sort options
              _showSortOptions(context);
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${orderProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshOrders,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshOrders,
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                if (index >= orderProvider.orders.length) return SizedBox.shrink();
                final order = orderProvider.orders[index];
                return OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Date (Newest first)'),
                onTap: () {
                  Navigator.pop(context);
                  // Sorting logic would go here
                },
              ),
              ListTile(
                title: Text('Date (Oldest first)'),
                onTap: () {
                  Navigator.pop(context);
                  // Sorting logic would go here
                },
              ),
              ListTile(
                title: Text('Status'),
                onTap: () {
                  Navigator.pop(context);
                  // Sorting logic would go here
                },
              ),
              ListTile(
                title: Text('Total (High to Low)'),
                onTap: () {
                  Navigator.pop(context);
                  // Sorting logic would go here
                },
              ),
              ListTile(
                title: Text('Total (Low to High)'),
                onTap: () {
                  Navigator.pop(context);
                  // Sorting logic would go here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final farm_order.FarmOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(16),
          childrenPadding: EdgeInsets.all(0),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₵${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items Header
                    Text(
                      'Items (${order.items.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Order Items List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          ...order.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: item.product.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              item.product.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(Icons.image, color: Colors.grey[400], size: 24);
                                              },
                                            ),
                                          )
                                        : Icon(Icons.image, color: Colors.grey[400], size: 24),
                                  ),
                                  title: Text(
                                    item.product.name,
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${item.quantity} x ₵${item.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                  trailing: Text(
                                    '₵${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ),
                                if (index < order.items.length - 1)
                                  Divider(height: 1, indent: 12, endIndent: 12, color: Colors.grey[200]),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Order Summary
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                              Text('₵${order.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                              Text('₵0.00', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Divider(height: 1, color: Colors.grey[300]),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              Text('₵${order.total.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Shipping Information
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Shipping Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            order.address,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.payment, size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Payment Method: ${order.paymentMethod}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

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
} 