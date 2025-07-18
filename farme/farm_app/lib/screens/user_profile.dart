import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final bool isAdmin;
  const UserProfilePage({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.isAdmin = false,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
   
    await Future.delayed(Duration(seconds: 1)); // Simulate async logout
    if (!mounted) return;
    setState(() => _isLoggingOut = false);
   
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('My Account'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // User Info
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: widget.avatarUrl.isNotEmpty ? NetworkImage(widget.avatarUrl) : null,
                  child: widget.avatarUrl.isEmpty ? Icon(Icons.person, size: 40) : null,
                ),
                SizedBox(height: 12),
                Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 4),
                Text(widget.email, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Icon(Icons.edit, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
          SizedBox(height: 28),
          // General Section
          Text('General', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          SizedBox(height: 8),
          _ProfileTile(icon: Icons.location_on, label: 'Location', onTap: () {}),
          _ProfileTile(icon: Icons.local_shipping, label: 'Pickup location', onTap: () {}),
          _ProfileTile(icon: Icons.receipt_long, label: 'My orders', onTap: () {}),
          _ProfileTile(icon: Icons.qr_code, label: 'Scan QR code', onTap: () {}),
          _ProfileTile(icon: Icons.lock_outline, label: 'Change password', onTap: () {}),
          if (widget.isAdmin) ...[
            SizedBox(height: 20),
            Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            SizedBox(height: 8),
            _ProfileTile(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
            _ProfileTile(icon: Icons.settings, label: 'Manage Products', onTap: () {}),
          ],
          SizedBox(height: 28),
          // Support Section
          Text('Support', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          SizedBox(height: 8),
          _ProfileTile(icon: Icons.chat_bubble_outline, label: 'Need help? Let’s chat', onTap: () {}),
          _ProfileTile(icon: Icons.verified_user_outlined, label: 'Lender Protection Guarantee', onTap: () {}),
          _ProfileTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
          SizedBox(height: 32),
          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _isLoggingOut ? null : _handleLogout,
            trailing: _isLoggingOut
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : null,
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
        title: Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
} 