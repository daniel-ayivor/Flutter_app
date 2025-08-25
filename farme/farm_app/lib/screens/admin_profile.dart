import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../authContext.dart';
import '../home/welcomepage.dart';
import 'edit_profile.dart';
import 'change_password.dart';

class AdminProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final String phone;
  final String address;
  
  const AdminProfilePage({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.phone = '',
    this.address = '',
  });

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> with TickerProviderStateMixin {
  bool _isLoggingOut = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: Colors.red, size: 28),
            ),
            SizedBox(width: 16),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of your account? You will need to sign in again to access your account.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      setState(() => _isLoggingOut = true);
      
      // Add haptic feedback
      HapticFeedback.mediumImpact();
      
      // Call the signOut method from AuthProvider
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();
      
      if (!mounted) return;
      
      setState(() => _isLoggingOut = false);
      // Navigate to login page after successful logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
        (route) => false,
      );
    }
  }

  void _navigateToEditProfile() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: widget.name,
          currentEmail: widget.email,
          currentPhone: widget.phone,
          currentAvatarUrl: widget.avatarUrl,
        ),
      ),
    );
    
    if (result == true) {
      // Profile was updated, you might want to refresh the data here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0A0A0A) : Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: screenHeight * 0.3,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Color(0xFF1A1A1A) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark 
                        ? [Color(0xFF2E7D32), Color(0xFF1B5E20)]
                        : [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 60),
                          // Profile Picture with Status Indicator
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: widget.avatarUrl.isNotEmpty 
                                      ? NetworkImage(widget.avatarUrl) 
                                      : null,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: widget.avatarUrl.isEmpty 
                                      ? Icon(Icons.person, size: 50, color: Colors.white) 
                                      : null,
                                ),
                              ),
                              // Online status indicator
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // User Name
                          Text(
                            widget.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          // User Email
                          Text(
                            widget.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          // User Role Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: _navigateToEditProfile,
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          
          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Products',
                          value: '24',
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.list_alt_outlined,
                          title: 'Orders',
                          value: '126',
                          color: Colors.red,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.group_outlined,
                          title: 'Users',
                          value: '893',
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Account Section
                  _SectionHeader(title: 'Account', isDark: isDark),
                  SizedBox(height: 12),
                  _ProfileTile(
                    icon: Icons.person_outline,
                    label: 'Personal Information',
                    subtitle: 'Update your details',
                    onTap: _navigateToEditProfile,
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.location_on_outlined,
                    label: 'Address Book',
                    subtitle: widget.address.isNotEmpty ? widget.address : 'Add your address',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                      );
                    },
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Admin Section
                  _SectionHeader(title: 'Admin Panel', isDark: isDark),
                  SizedBox(height: 12),
                  _ProfileTile(
                    icon: Icons.dashboard_outlined,
                    label: 'Admin Dashboard',
                    subtitle: 'Manage your business',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Navigate to admin dashboard
                    },
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.inventory_outlined,
                    label: 'Manage Products',
                    subtitle: 'Add, edit, or remove products',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Navigate to product management
                    },
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    subtitle: 'View business insights',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Navigate to analytics
                    },
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Support Section
                  _SectionHeader(title: 'Support & Legal', isDark: isDark),
                  SizedBox(height: 12),
                  _ProfileTile(
                    icon: Icons.help_outline,
                    label: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.chat_bubble_outline,
                    label: 'Contact Support',
                    subtitle: 'Chat with our support team',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  _ProfileTile(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Logout Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoggingOut ? null : _handleLogout,
                      icon: _isLoggingOut
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        _isLoggingOut ? 'Logging out...' : 'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // App Version
                  Center(
                    child: Text(
                      'Farm App v1.0.0',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Coming soon!'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _StatsCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.green.shade700, size: 24),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}