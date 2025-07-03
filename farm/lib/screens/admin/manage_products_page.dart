import 'package:flutter/material.dart';
import 'add_product_page.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List<Map<String, dynamic>> products = [
    {
      'name': 'Fresh Tomatoes',
      'image': 'https://placehold.co/600x400/FF0000/FFFFFF?text=Tomatoes',
      'price': 2.99,
      'rating': 4.5,
      'description': 'Juicy, ripe tomatoes perfect for salads and cooking.',
      'category': 'Vegetables',
    },
    {
      'name': 'Organic Apples',
      'image': 'https://placehold.co/600x400/FFA500/FFFFFF?text=Apples',
      'price': 3.50,
      'rating': 4.8,
      'description': 'Crisp and sweet organic apples, great for a healthy snack.',
      'category': 'Fruits',
    },
  ];

  void showAddProductModal() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: AddProductForm(
            onAdd: (product) {
              setState(() {
                products.add(product);
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showUpdateProductModal(int index) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: AddProductForm(
            initial: products[index],
            onAdd: (product) {
              setState(() {
                products[index] = product;
              });
              Navigator.pop(context);
            },
            isUpdate: true,
          ),
        ),
      ),
    );
  }

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Rating')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            ...products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return DataRow(cells: [
                DataCell(Text(product['name'].toString())),
                DataCell(Image.network(product['image'], width: 50, height: 50)),
                DataCell(Text('₵${product['price']}')),
                DataCell(Text(product['rating'].toString())),
                DataCell(SizedBox(width: 120, child: Text(product['description'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis))),
                DataCell(Text(product['category'].toString())),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => showUpdateProductModal(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteProduct(index),
                    ),
                  ],
                )),
              ]);
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductModal,
        backgroundColor: Colors.green,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddProductForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? initial;
  final bool isUpdate;
  const AddProductForm({super.key, required this.onAdd, this.initial, this.isUpdate = false});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String imageUrl;
  late String price;
  late String rating;
  late String description;
  late String category;

  @override
  void initState() {
    super.initState();
    name = widget.initial?['name'] ?? '';
    imageUrl = widget.initial?['image'] ?? '';
    price = widget.initial?['price']?.toString() ?? '';
    rating = widget.initial?['rating']?.toString() ?? '';
    description = widget.initial?['description'] ?? '';
    category = widget.initial?['category'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.isUpdate ? 'Update Product' : 'Add Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Product Name'),
              onChanged: (val) => name = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter product name' : null,
            ),
            TextFormField(
              initialValue: imageUrl,
              decoration: const InputDecoration(labelText: 'Image URL'),
              onChanged: (val) => imageUrl = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter image URL' : null,
            ),
            TextFormField(
              initialValue: price,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (val) => price = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
            ),
            TextFormField(
              initialValue: rating,
              decoration: const InputDecoration(labelText: 'Rating'),
              keyboardType: TextInputType.number,
              onChanged: (val) => rating = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter rating' : null,
            ),
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (val) => description = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
            ),
            TextFormField(
              initialValue: category,
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
                    widget.onAdd({
                      'name': name,
                      'image': imageUrl,
                      'price': double.tryParse(price) ?? 0.0,
                      'rating': double.tryParse(rating) ?? 0.0,
                      'description': description,
                      'category': category,
                    });
                  }
                },
                child: Text(widget.isUpdate ? 'Update Product' : 'Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 