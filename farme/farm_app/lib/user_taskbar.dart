import 'package:flutter/material.dart';
import 'screens/product_listing.dart';
import 'screens/cart_screen.dart';
import 'screens/order_history.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'authContext.dart';
import 'screens/user_profile.dart';
import 'providers/cart_provider.dart';

class UserTaskbar extends StatefulWidget {
  const UserTaskbar({super.key});

  @override
  State<UserTaskbar> createState() => _UserTaskbarState();
}

class _UserTaskbarState extends State<UserTaskbar> {
  int _selectedIndex = 0;
  
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(),
      ProductListingPage(),
      CartScreen(),
      OrderHistoryScreen(),
      // Placeholder, will be replaced in build
      Container(),
    ];
    // Check for initial tab index from route arguments
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int && args >= 0 && args < _pages.length) {
        setState(() {
          _selectedIndex = args;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = authProvider.role == 'admin';
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final avatarUrl = user?.photoURL ?? '';
    _pages[4] = UserProfilePage(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isAdmin: isAdmin,
    );
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Products'),
              BottomNavigationBarItem(
                icon: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    final count = cart.itemCount;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_cart_outlined),
                        if (count > 0)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container
                              (
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green.shade700,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
            elevation: 8,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
