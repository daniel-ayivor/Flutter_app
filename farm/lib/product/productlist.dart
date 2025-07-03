import 'package:flutter/material.dart';

// 1. Product Model
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final String description; // Added for product details page

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.description = 'A detailed description of the product.',
  });
}

// 2. Product Details Page (Placeholder)
class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero( // Hero animation for smooth image transition
              tag: product.id,
              child: Image.asset(
                product.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        ' ${product.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Text(' (120 reviews)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${product.name} to cart!')),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Product List Page
class Productlist extends StatefulWidget {
  const Productlist({super.key});

  @override
  State<Productlist> createState() => _ProductlistState();
}

class _ProductlistState extends State<Productlist> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample Data for Categories
  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Beverages',
    'Dairy',
    'Meat',
    'Seafood',
    'Spices',
  ];

  // Sample Data for Products
  final List<Product> _allProducts = [
    Product(
      id: 'p1',
      name: 'Green pepper',
      imageUrl: 'lib/assets/green-chili-peppers.jpg',
      price: 2.99,
      rating: 4.5,
      description: 'Juicy, ripe tomatoes perfect for salads and cooking.',
    ),
    Product(
      id: 'p2',
      name: 'Organic Apples',
      imageUrl: 'lib/assets/11473559.png',
      price: 3.50,
      rating: 4.8,
      description: 'Crisp and sweet organic apples, great for a healthy snack.',
    ),
    Product(
      id: 'p3',
      name: 'Whole beans',
      imageUrl: 'lib/assets/1247d03d-2cc4-4e55-8420-6fe754a95d77.jpg',
      price: 4.25,
      rating: 4.2,
      description: 'Nutritious whole wheat bread, baked fresh daily.',
    ),
    Product(
      id: 'p4',
      name: 'Pepper',
      imageUrl: 'lib/assets/cooking-ingredient-eat-bell-pepper-nutrition.jpg',
      price: 5.75,
      rating: 4.6,
      description: 'Creamy and delicious almond milk, a great dairy alternative.',
    ),
    Product(
      id: 'p5',
      name: 'Beans',
      imageUrl: 'lib/assets/fd90aad7-5a1a-4d47-b6cb-6c6a6dfc6842.jpg',
      price: 1.80,
      rating: 4.3,
      description: 'Fresh, crunchy carrots, ideal for juicing or stir-fries.',
    ),
    Product(
      id: 'p6',
      name: 'Orange',
      imageUrl: 'lib/assets/food_11034759.png',
      price: 1.20,
      rating: 4.7,
      description: 'Sweet and energy-rich bananas, perfect for smoothies.',
    ),
    Product(
      id: 'p7',
      name: 'Fresh Tomatoes',
      imageUrl: 'lib/assets/tomatoes.jpg',
      price: 6.00,
      rating: 4.4,
      description: 'Premium quality brown rice, a healthy staple for any meal.',
    ),
    Product(
      id: 'p8',
      name: 'Fresh pepper',
      imageUrl: 'lib/assets/red-fresh-chili-peppers-isolated-white.jpg',
      price: 3.99,
      rating: 4.1,
      description: '100% natural orange juice, no added sugar.',
    ),
  ];

  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts; // Initialize with all products
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProducts();
    });
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farme Products'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // Height for the search bar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.green[700], // Darker green for the search bar background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Carousel
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: SizedBox(
              height: 40, // Height for the category buttons
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: false, // You can add state management for selection
                      onSelected: (selected) {
                        // TODO: Implement category filtering logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${categories[index]} category selected!')),
                        );
                      },
                      selectedColor: Colors.green,
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Product Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        crossAxisSpacing: 16.0, // Spacing between columns
                        mainAxisSpacing: 16.0, // Spacing between rows
                        childAspectRatio: 0.7, // Adjust as needed for content
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index]; // Use filtered products
                        return GestureDetector(
                          onTap: () {
                            // Navigate to product details page on tap
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(product: product),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Hero( // Hero animation for smooth image transition
                                    tag: product.id,
                                    child: Image.asset(
                                      product.imageUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          Text(
                                            ' ${product.rating.toStringAsFixed(1)}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Added ${product.name} to cart!')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            minimumSize: Size.zero, // Remove default minimum size
                                          ),
                                          child: const Text('Buy'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}