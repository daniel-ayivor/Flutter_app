import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../model/cart_item.dart';
import 'checkout_screen.dart';
import 'product_listing.dart';

class CartScreen extends StatelessWidget {
  static const double shippingFee = 80.0;
  static const double vatPercent = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Shopping Cart'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
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
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListingPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          final subtotal = cartProvider.total;
          final vat = subtotal * vatPercent / 100;
          final total = subtotal + shippingFee + vat;

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _CartItemCard(item: item);
                  },
                ),
              ),

              // Cart Summary
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((0.12 * 255).toInt()),
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _CartSummaryRow(label: 'Sub-total', value: subtotal),
                    _CartSummaryRow(label: 'VAT (%)', value: vat),
                    _CartSummaryRow(label: 'Shipping fee', value: shippingFee),
                    Divider(height: 28),
                    _CartSummaryRow(label: 'Total', value: total, isTotal: true),
                    SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Go To Checkout'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Remove Card, just use Padding for spacing
        Padding(
          padding: const EdgeInsets.only(bottom: 18, left: 0, right: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: item.product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
              SizedBox(width: 14),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '₵${item.product.price.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
              // Quantity Selector
              Padding(
                padding: const EdgeInsets.only(top: 12.0), // Move down by 12 pixels
                child: Row(
                  children: [
                    // Decrease button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 0.7),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 2, right: 4),
                      child: IconButton(
                        icon: Icon(Icons.remove, size: 14), // smaller icon
                        splashRadius: 14,
                        padding: EdgeInsets.all(0),
                        constraints: BoxConstraints(minWidth: 22, minHeight: 22), // smaller height
                        onPressed: () {
                          context.read<CartProvider>().updateQuantity(
                            item.product.id,
                            item.quantity - 1,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    // Increase button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 0.7),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 2, left: 4),
                      child: IconButton(
                        icon: Icon(Icons.add, size: 14), // smaller icon
                        splashRadius: 14,
                        padding: EdgeInsets.all(0),
                        constraints: BoxConstraints(minWidth: 22, minHeight: 22), // smaller height
                        onPressed: () {
                          context.read<CartProvider>().updateQuantity(
                            item.product.id,
                            item.quantity + 1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Remove (X) icon at top right
        Positioned(
          top: 0, // Move it higher
          right: 0, // Align to the right edge of the item row
          child: GestureDetector(
            onTap: () {
              context.read<CartProvider>().removeItem(item.product.id);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.close, color: Colors.grey[500], size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  const _CartSummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 15,
            ),
          ),
          Text(
            '₵${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 15,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
