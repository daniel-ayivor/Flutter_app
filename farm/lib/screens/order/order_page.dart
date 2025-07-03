import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // Dummy cart data
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Fresh Tomatoes',
      'image': 'https://placehold.co/600x400/FF0000/FFFFFF?text=Tomatoes',
      'price': 2.99,
      'quantity': 2,
    },
    {
      'name': 'Organic Apples',
      'image': 'https://placehold.co/600x400/FFA500/FFFFFF?text=Apples',
      'price': 3.50,
      'quantity': 1,
    },
  ];
  String paymentMethod = 'Mobile Money';
  String address = '';
  bool isPlacingOrder = false;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get shipping => 5.0;
  double get tax => subtotal * 0.05;
  double get total => subtotal + shipping + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cart Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...cartItems.map((item) => Card(
                child: ListTile(
                  leading: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item['name']),
                  subtitle: Text('₵${item['price']} x ${item['quantity']}'),
                  trailing: Text('₵${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                ),
              )),
              const SizedBox(height: 24),
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'Mobile Money', child: Text('Mobile Money')),
                  DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'Pay on Delivery', child: Text('Pay on Delivery')),
                ],
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),
              const SizedBox(height: 24),
              const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                decoration: const InputDecoration(hintText: 'Enter delivery address'),
                onChanged: (val) => address = val,
              ),
              const SizedBox(height: 24),
              const Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Subtotal'),
                trailing: Text('₵${subtotal.toStringAsFixed(2)}'),
              ),
              ListTile(
                title: const Text('Shipping'),
                trailing: Text('₵${shipping.toStringAsFixed(2)}'),
              ),
              ListTile(
                title: const Text('Tax'),
                trailing: Text('₵${tax.toStringAsFixed(2)}'),
              ),
              const Divider(),
              ListTile(
                title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('₵${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isPlacingOrder
                      ? null
                      : () async {
                          setState(() => isPlacingOrder = true);
                          await Future.delayed(const Duration(seconds: 2));
                          setState(() => isPlacingOrder = false);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Order Placed!'),
                              content: const Text('Thank you for your purchase.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                  child: isPlacingOrder
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Place Order', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 