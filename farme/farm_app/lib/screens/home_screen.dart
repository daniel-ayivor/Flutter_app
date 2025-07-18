import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authContext.dart';
import '../providers/product_provider.dart';
import '../screens/product_listing.dart';
import '../model/product.dart';
import '../screens/product_detail.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _categoryPageController;

  @override
  void initState() {
    super.initState();
    _categoryPageController = PageController(viewportFraction: 0.35);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _categoryPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categories =
        productProvider.categories.where((c) => c != 'All').toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Farm App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black87),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeBanner(),
            SizedBox(height: 16),

                // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[800]),
                  ),
                ),
                SizedBox(height: 8),

            SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: _categoryPageController,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _CategoryCard(
                        label: category,
                        iconAsset: _categoryIcon(category),
                        onTap: () {
                          productProvider.setCategoryFilter(category);
                          Navigator.push(
                            context,
                              MaterialPageRoute(
                                  builder: (_) => ProductListingPage()),
                          );
                        },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Featured Products',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[800]),
                  ),
                ),
                SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildProductGrid(productProvider),
                ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return Container(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      );
    }

    if (productProvider.products.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Text(
            'No products available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

                    final products = productProvider.products.take(6).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
                      itemBuilder: (context, index) {
        return _ProductCardHome(product: products[index]);
      },
    );
  }
}

class _HomeBanner extends StatefulWidget {
  @override
  State<_HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<_HomeBanner> {
  late final PageController _pageController;
  int _currentPage = 1;
  late final List<_BannerItem> _bannerItems;
  late final List<_BannerItem> _loopedItems;

  @override
  void initState() {
    super.initState();
    _bannerItems = [
       _BannerItem(
        image: 'lib/asset/woman-shopping-vegetables-supermarket.jpg',
        text: 'Discover fresh agricultural products',
        buttonText: 'Shop Now',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductListingPage()),
                    );
                  },
                ),
      _BannerItem(
        image: 'lib/asset/man-delivering-groceries-customers.jpg',
        text: 'Fast Delivery to Your Doorstep',
        buttonText: 'Order Now',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductListingPage()),
          );
        },
      ),
      _BannerItem(
        image: 'lib/asset/1247d03d-2cc4-4e55-8420-6fe754a95d77.jpg',
        text: 'Fresh Vegetables Everyday',
        buttonText: 'See Vegetables',
        onTap: (context) {
          Provider.of<ProductProvider>(context, listen: false).setCategoryFilter('Vegetables');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductListingPage()),
          );
        },
      ),
      _BannerItem(
        image: 'lib/asset/fd90aad7-5a1a-4d47-b6cb-6c6a6dfc6842.jpg',
        text: 'Best Grains and Cereals',
        buttonText: 'See Grains',
        onTap: (context) {
          Provider.of<ProductProvider>(context, listen: false).setCategoryFilter('Grains and Cereal');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductListingPage()),
          );
        },
      ),
      _BannerItem(
        image: 'lib/asset/food_11034759.png',
        text: 'Seeds & Seedlings for Your Farm',
        buttonText: 'Browse Seeds',
        onTap: (context) {
          Provider.of<ProductProvider>(context, listen: false).setCategoryFilter('Seeds or Seedlings');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductListingPage()),
          );
        },
      ),
    ];
    
    _loopedItems = [_bannerItems.last, ..._bannerItems, _bannerItems.first];
    _pageController = PageController(initialPage: 1);
    _startAutoScroll();
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 5));
      if (!mounted || !_pageController.hasClients) break;
      int nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
    if (index == _loopedItems.length - 1) {
      Future.delayed(Duration(milliseconds: 350), () {
        if (mounted) _pageController.jumpToPage(1);
      });
    } else if (index == 0) {
      Future.delayed(Duration(milliseconds: 350), () {
        if (mounted) _pageController.jumpToPage(_loopedItems.length - 2);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 160,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _loopedItems.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final item = _loopedItems[index];
              return GestureDetector(
                onTap: () => item.onTap(context),
      child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset(
                          item.image,
                fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                          ),
              ),
              Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
              ),
              Padding(
                          padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                              Text(
                                item.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                                  foregroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => item.onTap(context),
                                child: Text(item.buttonText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _bannerItems.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage - 1 == entry.key ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerItem {
  final String image;
  final String text;
  final String buttonText;
  final void Function(BuildContext) onTap;

  _BannerItem({
    required this.image,
    required this.text,
    required this.buttonText,
    required this.onTap,
  });
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Column(
          children: [
          Container(
              width: 70,
              height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
              borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                iconAsset,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.category, size: 40),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
    );
  }
}

class _ProductCardHome extends StatelessWidget {
  final Product product;

  const _ProductCardHome({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

String _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'fruits':
      return 'lib/asset/11473559.png';
    case 'vegetables':
      return 'lib/asset/1247d03d-2cc4-4e55-8420-6fe754a95d77.jpg';
    case 'grains and cereal':
      return 'lib/asset/fd90aad7-5a1a-4d47-b6cb-6c6a6dfc6842.jpg';
    case 'livestock':
      return 'lib/asset/letter-f_8057804.png';
    case 'seeds or seedlings':
      return 'lib/asset/food_11034759.png';
    case 'equipment':
      return 'lib/asset/google_720255.png';
    default:
      return 'lib/asset/11473559.png';
  }
} 