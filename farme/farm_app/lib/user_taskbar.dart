import 'package:flutter/material.dart';
import 'screens/product_listing.dart';
import 'screens/cart_screen.dart';
import 'screens/order_history.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'authContext.dart';
import 'screens/user_profile.dart';

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
      ProductListingPage(),
      CartScreen(),
      HomeScreen(),
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
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Products'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
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
