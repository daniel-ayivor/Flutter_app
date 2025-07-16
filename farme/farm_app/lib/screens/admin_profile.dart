import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authContext.dart';

class AdminProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final role = authProvider.role ?? 'admin';

    // Placeholder data for stats
    final int scans = 126, maxScans = 750;
    final int users = 1, maxUsers = 2;
    final int codes = 893, maxCodes = 2500;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: user == null
            ? Center(child: Text('No admin logged in'))
            : Column(
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Icon(Icons.person, size: 44, color: Colors.deepPurple)
                                : null,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          user.displayName ?? user.email ?? 'Admin',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Role: $role',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileStat(label: 'Scans', value: '$scans/$maxScans'),
                            _ProfileStat(label: 'Users', value: '$users/$maxUsers'),
                            _ProfileStat(label: 'Codes', value: '$codes/$maxCodes'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Profile Menu
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        children: [
                          _ProfileMenuItem(icon: Icons.settings, label: 'Settings', onTap: () {}),
                          _ProfileMenuItem(icon: Icons.credit_card, label: 'Billing Details', onTap: () {}),
                          _ProfileMenuItem(icon: Icons.group, label: 'User Management', onTap: () {}),
                          _ProfileMenuItem(icon: Icons.info_outline, label: 'Information', onTap: () {}),
                          Divider(),
                          _ProfileMenuItem(
                            icon: Icons.logout,
                            label: 'Log out',
                            onTap: () => authProvider.signOut(),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(label, style: TextStyle(color: color ?? Colors.black)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
} 