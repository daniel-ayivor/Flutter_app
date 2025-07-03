import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String imageUrl = '';
  String price = '';
  String rating = '';
  String description = '';
  String category = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (val) => name = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (val) => imageUrl = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter image URL' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (val) => price = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                onChanged: (val) => rating = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter rating' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => description = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (val) => category = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Product Added'),
                          content: const Text('The product has been added successfully.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 