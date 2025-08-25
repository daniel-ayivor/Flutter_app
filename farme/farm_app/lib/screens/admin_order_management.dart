import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../model/order.dart' as farm_order;

class AdminOrderManagement extends StatefulWidget {
  @override
  _AdminOrderManagementState createState() => _AdminOrderManagementState();
}

class _AdminOrderManagementState extends State<AdminOrderManagement> {
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderProvider>().fetchAllOrders();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status ?? 'All';
    });
  }

  Future<void> _refreshOrders() async {
    context.read<OrderProvider>().fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(
                  onSearchChanged: _onSearchChanged,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text('Filter by status:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Processing', child: Text('Processing')),
                      DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
                      DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                      DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: _onStatusChanged,
                  ),
                ],
              ),
            ),
            // Order List
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  if (orderProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (orderProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Error: ${orderProvider.error}'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => orderProvider.fetchAllOrders(),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Apply filters
                  final filteredOrders = orderProvider.orders.where((order) {
                    final orderId = order.id.toLowerCase();
                    final userId = order.userId.toLowerCase();
                    final matchesSearch = _searchQuery.isEmpty || 
                        orderId.contains(_searchQuery) || 
                        userId.contains(_searchQuery);
                    
                    final matchesStatus = _selectedStatus == 'All' || order.status == _selectedStatus;
                    
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 100, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No orders yet' : 'No orders found',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'Orders will appear here when customers place them' 
                              : 'No orders match your search criteria',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return AdminOrderCard(order: order);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminOrderCard extends StatelessWidget {
  final farm_order.FarmOrder order;

  const AdminOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
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
                    'User: ${order.userId.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                Text(
                  'Items:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product Image
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: item.product.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image, color: Colors.grey);
                                  },
                                ),
                              )
                            : Icon(Icons.image, color: Colors.grey),
                      ),
                      SizedBox(width: 12),
                      // Name and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${item.quantity} x ₵${item.product.price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Total Price
                      Text(
                        '₵${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                )),
                
                SizedBox(height: 16),
                
                // Shipping Information
                Text(
                  'Shipping Information:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.address,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Payment: ${order.paymentMethod}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Status Update
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: order.status,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        items: [
                          'Pending',
                          'Processing',
                          'Shipped',
                          'Delivered',
                          'Cancelled',
                        ].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            context.read<OrderProvider>().updateOrderStatus(
                              order.id,
                              newStatus,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

class OrderSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearchChanged;

  OrderSearchDelegate({required this.onSearchChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchChanged(query);
    return Container(); // We're handling the search in the main screen
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearchChanged(query);
    return Container(); // We're handling the search in the main screen
  }
}