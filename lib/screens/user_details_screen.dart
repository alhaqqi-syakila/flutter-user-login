import 'package:flutter/material.dart';
import '../models/user.dart';
import 'user_form_screen.dart';

class UserDetailsScreen extends StatelessWidget {
    
  final Color primaryColor = Color(0xFF5600D8);
  final Color backgroundColor = Color(0xFF151515);
  final Color cardBackgroundColor = Color(0xFF1D1D1D);
  final Color cardBackgroundColor2 = Color(0xFF212121);
  final Color textColorPrimary = Colors.white;
  final Color textColorSecondary = Colors.white70;
  final Color editColor = Color(0xFFEEAF00);
  final Color deleteColor = Color(0xFFEE0000);
  final User user;

  UserDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColorPrimary,
        title: Text(
          'User Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColorPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(user),
                          style: TextStyle(
                            color: textColorPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColorPrimary,
                      ),
                    ),
                    if (user.fullName != null && user.fullName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          user.fullName!,
                          style: TextStyle(fontSize: 16, color: textColorPrimary),
                        ),
                      ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 16, color: Color(0x63FFFFFF)),
                    ),
                  ],
                ),
              ),

              // User information section
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Account Information'),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.person,
                      title: 'Username',
                      value: user.username,
                    ),
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: user.email,
                    ),
                    if (user.fullName != null && user.fullName!.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.badge,
                        title: 'Full Name',
                        value: user.fullName!,
                      ),
                    _buildInfoCard(
                      icon: Icons.numbers,
                      title: 'User ID',
                      value: user.id.toString(),
                    ),

                    SizedBox(height: 24),

                    // Action buttons
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColorPrimary,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textColorPrimary, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: textColorPrimary.withOpacity(0.7)),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColorPrimary,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  String _getInitials(User user) {
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      final nameParts = user.fullName!.split(' ');
      if (nameParts.length > 1) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      }
    }
    return user.username.substring(0, 1).toUpperCase();
  }
}
