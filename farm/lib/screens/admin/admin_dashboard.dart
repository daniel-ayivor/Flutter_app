import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Admin Operations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                // Navigate to add product page
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Update Product'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                // Navigate to update product page
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete Product'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Navigate to delete product page
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Manage All Products'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(context, '/admin/manage-products');
              },
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Admin Profile'),
              onPressed: () {
                // Navigate to admin profile page
              },
            ),
          ],
        ),
      ),
    );
  }
} 