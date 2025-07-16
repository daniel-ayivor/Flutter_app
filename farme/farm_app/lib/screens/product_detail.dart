import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 24, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(product.imageUrl, height: 180, width: 180, fit: BoxFit.cover),
                        )
                      : Container(height: 180, width: 180, color: Colors.grey[200]),
                ),
              ),
              // Product Name
              Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(height: 4),
              // You can add address/location here if available
              SizedBox(height: 16),
              // Quantity Selector
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() {
                      if (quantity > 1) quantity--;
                    }),
                  ),
                  Text('$quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() {
                      quantity++;
                    }),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Stats
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(product.rating.toString()),
                  // You can add time/calories here if you add them to your model
                ],
              ),
              SizedBox(height: 16),
              // Description
              Text(product.description, style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 24),
              // Price and Add to Cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total amount', style: TextStyle(color: Colors.grey[600])),
                  Text(' 24${(product.price * quantity).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < quantity; i++) {
                      context.read<CartProvider>().addItem(product);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Add to cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 