import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onRoleChanged(String? role) {
    setState(() {
      _selectedRole = role ?? 'All';
    });
  }

  Future<void> _refreshUsers() async {
    // In a real app, you might want to refresh the data from the server
    // For now, we'll just wait a moment to simulate network activity
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(
                  onSearchChanged: _onSearchChanged,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text('Filter by role:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'user', child: Text('User')),
                    ],
                    onChanged: _onRoleChanged,
                  ),
                ],
              ),
            ),
            // User List
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('email', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 12),
                          Text('Failed to load users: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  
                  // Apply filters
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data();
                    final name = (data['name'] as String?)?.trim().toLowerCase();
                    final email = (data['email'] as String?)?.trim().toLowerCase() ?? '';
                    final role = (data['role'] as String?)?.trim() ?? 'user';
                    
                    final matchesSearch = _searchQuery.isEmpty || 
                        (name != null && name.contains(_searchQuery)) || 
                        email.contains(_searchQuery);
                    
                    final matchesRole = _selectedRole == 'All' || role == _selectedRole;
                    
                    return matchesSearch && matchesRole;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 100, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No users found',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'Users will appear here after they sign up' 
                              : 'No users match your search criteria',
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data();
                      final id = filteredDocs[index].id;
                      final name = (data['name'] as String?)?.trim();
                      final email = (data['email'] as String?)?.trim() ?? 'unknown@email';
                      final role = (data['role'] as String?)?.trim() ?? 'user';
                      final photoUrl = (data['photoUrl'] as String?)?.trim();
                      final phone = (data['phone'] as String?)?.trim();

                      return _UserCard(
                        id: id,
                        name: name,
                        email: email,
                        role: role,
                        photoUrl: photoUrl,
                        phone: phone,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String id;
  final String? name;
  final String email;
  final String role;
  final String? photoUrl;
  final String? phone;

  const _UserCard({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey[200],
          backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
              ? NetworkImage(photoUrl!)
              : null,
          child: (photoUrl == null || photoUrl!.isEmpty)
              ? Container(
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (name?.isNotEmpty == true ? name![0] : email[0]).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(role),
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        title: Text(
          (name == null || name!.isEmpty) ? email : name!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null && name!.isNotEmpty) 
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            if (phone != null && phone!.isNotEmpty)
              Text(
                phone!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(role),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#${id.substring(0, id.length >= 6 ? 6 : id.length)}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {
                // Show options for this user
                _showUserOptions(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.green;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showUserOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit User'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement edit user functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete User'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement delete user functionality
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearchChanged;

  UserSearchDelegate({required this.onSearchChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchChanged(query);
    return Container(); // We're handling the search in the main screen
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearchChanged(query);
    return Container(); // We're handling the search in the main screen
  }
}
