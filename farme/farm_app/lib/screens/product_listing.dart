import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../model/product.dart';
import 'product_detail.dart';
import 'cart_screen.dart';

class ProductListingPage extends StatefulWidget {
  @override
  _ProductListingPageState createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farm Products'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${context.watch<CartProvider>().itemCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error:  ${productProvider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.fetchProducts(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (productProvider.filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No products found'),
                  SizedBox(height: 8),
                  Text('Try adjusting your search or filters'),
                ],
              ),
            );
          }

          final trustedPicks = productProvider.filteredProducts.take(2).toList();
          final recommended = productProvider.filteredProducts.skip(2).toList();

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // ✅ Updated Search Bar
              TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                ),
                onChanged: (value) {
                  context.read<ProductProvider>().setSearchQuery(value);
                },
              ),
              SizedBox(height: 24),
              // Trusted Picks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your trusted picks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  if (trustedPicks.length > 2)
                    Text('View all', style: TextStyle(color: Colors.green)),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trustedPicks.length,
                  separatorBuilder: (_, __) => SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final product = trustedPicks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: _ProductCardHorizontal(product: product),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              // Recommended
              Text('Recommended', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              ...recommended.map((product) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: _ProductCardVertical(product: product),
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCardHorizontal extends StatelessWidget {
  final Product product;
  const _ProductCardHorizontal({required this.product});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          product.imageUrl.isNotEmpty
              ? Image.network(product.imageUrl, height: 60)
              : Container(height: 60, color: Colors.grey[200]),
          SizedBox(height: 8),
          Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(product.rating.toString()),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' 24${product.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black,
                child: Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCardVertical extends StatelessWidget {
  final Product product;
  const _ProductCardVertical({required this.product});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          product.imageUrl.isNotEmpty
              ? Image.network(product.imageUrl, height: 60)
              : Container(height: 60, width: 60, color: Colors.grey[200]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(product.rating.toString()),
                  ],
                ),
                Text(' 24${product.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
