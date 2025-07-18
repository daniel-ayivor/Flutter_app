import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authContext.dart';
import '../providers/product_provider.dart';
import '../screens/product_listing.dart';
import '../model/product.dart';
import '../screens/product_detail.dart'; // Correct import for ProductDetailPage

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories.where((c) => c != 'All').toList();
    final double gridHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Farm App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            _HomeBanner(),
            SizedBox(height: 16),
            // Categories Row (scrollable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 , color: const Color.fromARGB(221, 52, 52, 52))),
            ),
            // Replace the ListView.separated for categories with a PageView carousel
            SizedBox(
              height: 130,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.35),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: _CategoryCard(
                      label: category,
                      iconAsset: _categoryIcon(category),
                      onTap: () {
                        productProvider.setCategoryFilter(category);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductListingPage()),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            // Product Grid Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Flash Deals for You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: const Color.fromARGB(31, 0, 0, 0))),
            ),
            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: SizedBox(
                height: gridHeight,
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    final products = productProvider.products.take(6).toList();
                    if (productProvider.isLoading) {
                      return Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (products.isEmpty) {
                      return Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No products found.'),
                      ));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8, // slightly taller cells
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductCardHome(product: product);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBanner extends StatefulWidget {
  @override
  State<_HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<_HomeBanner> {
  late final PageController _pageController;
  int _currentPage = 1; // Start at 1 for fake infinite loop
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
    // Fake infinite: [last, ...originals, first]
    _loopedItems = [
      _bannerItems.last,
      ..._bannerItems,
      _bannerItems.first,
    ];
    _pageController = PageController(initialPage: 1); // No viewportFraction, default is 1.0
    Future.delayed(Duration.zero, _startAutoScroll);
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 5));
      if (!mounted) break;
      int nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // If at the fake last, jump to real first
    if (index == _loopedItems.length - 1) {
      Future.delayed(Duration(milliseconds: 350), () {
        if (!_pageController.hasClients) return;
        _pageController.jumpToPage(1);
        setState(() {
          _currentPage = 1;
        });
      });
    }
    // If at the fake first, jump to real last
    else if (index == 0) {
      Future.delayed(Duration(milliseconds: 350), () {
        if (!_pageController.hasClients) return;
        _pageController.jumpToPage(_loopedItems.length - 2);
        setState(() {
          _currentPage = _loopedItems.length - 2;
        });
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 140,
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.15),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            item.image,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.45),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.text,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  ),
                                  onPressed: () => item.onTap(context),
                                  child: Text(item.buttonText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
            // Page indicator
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_bannerItems.length, (i) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  width: (_currentPage - 1) == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: (_currentPage - 1) == i ? Colors.green : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerItem {
  final String image;
  final String text;
  final String buttonText;
  final void Function(BuildContext) onTap;
  _BannerItem({required this.image, required this.text, required this.buttonText, required this.onTap});
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onTap;
  const _CategoryCard({required this.label, required this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06), // reduced opacity
                      blurRadius: 3, // reduced blur
                      offset: Offset(0, 2), // softer offset
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(iconAsset, fit: BoxFit.contain, width: 48, height: 48),
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _ProductCardHome extends StatelessWidget {
  final Product product;
  const _ProductCardHome({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: SizedBox(
        height: 190, // Fixed height to prevent overflow
        child: Card(
          elevation: 2, // reduced elevation
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 1.1, // slightly less tall
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl, fit: BoxFit.cover)
                        : Container(color: Colors.grey[200], child: Icon(Icons.image, size: 36, color: Colors.grey)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      '\u20b5${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 