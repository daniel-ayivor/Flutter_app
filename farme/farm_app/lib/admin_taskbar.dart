import 'package:flutter/material.dart';
import 'screens/admin_product_management.dart';
import 'screens/admin_order_management.dart';
import 'screens/admin_profile.dart';
import 'screens/admin_analytics.dart';

class AdminTaskbar extends StatefulWidget {
  const AdminTaskbar({super.key});

  @override
  State<AdminTaskbar> createState() => _AdminTaskbarState();
}

class _AdminTaskbarState extends State<AdminTaskbar> {
  int _selectedIndex = 0;
  
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminProductManagement(),
      AdminOrderManagement(),
      AdminProfilePage(),
      AdminAnalyticsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepPurple,
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
