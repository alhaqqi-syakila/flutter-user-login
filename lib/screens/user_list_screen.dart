import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with SingleTickerProviderStateMixin {
  late Future<List<User>> _usersFuture;
  final ApiService _apiService = ApiService();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final Color _primaryColor = Color(0xFF6200EE);
  final Color _accentColor = Color(0xFF03DAC6);
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    _fabAnimationController.forward();
  }
  
  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _usersFuture = _apiService.getUsers();
  }

  Future<Future<List<User>>> _refreshUsers() async {
    setState(() {
      _loadUsers();
    });
    return _usersFuture;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Users Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              // Add a nice animation before logout
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Logging out...',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              
              // Simulate a short delay for visual feedback
              await Future.delayed(Duration(milliseconds: 800));
              
              Navigator.pop(context); // Close the dialog
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            alignment: Alignment.centerLeft,
            child: Text(
              'All registered users',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _primaryColor,
              onRefresh: _refreshUsers,
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[300],
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading users',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _refreshUsers,
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            color: Colors.grey[400],
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add a new user with the button below',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      // Show user detail or quick actions
                                      _showUserOptions(user);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: _getAvatarColor(user.username),
                                            radius: 25,
                                            child: Text(
                                              _getInitials(user),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.username,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  user.email,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                if (user.fullName != null && user.fullName!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      user.fullName!,
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.grey[800],
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit, color: const Color.fromARGB(200, 0, 0, 0)),
                                                splashRadius: 24,
                                                tooltip: 'Edit User',
                                                onPressed: () async {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserFormScreen(user: user),
                                                    ),
                                                  );
                                                  if (result == true) {
                                                    _refreshUsers();
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete, color: const Color.fromARGB(200, 0, 0, 0)),
                                                splashRadius: 24,
                                                tooltip: 'Delete User',
                                                onPressed: () {
                                                  _showDeleteConfirmation(user);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => UserFormScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
            if (result == true) {
              _refreshUsers();
            }
          },
          backgroundColor: Colors.black,
          icon: Icon(Icons.person_add, color: Colors.white,),
          label: Text(
            'Add User',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
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

  Color _getAvatarColor(String username) {
    final colors = [
      Colors.blue[600]!,
      Colors.purple[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
      Colors.red[600]!,
    ];
    
    final index = username.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[index];
  }

  void _showUserOptions(User user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAvatarColor(user.username),
                  radius: 30,
                  child: Text(
                    _getInitials(user),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (user.fullName != null && user.fullName!.isNotEmpty)
                        Text(
                          user.fullName!,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                          ),
                        ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.edit, color: _primaryColor),
              title: Text('Edit User', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserFormScreen(user: user),
                  ),
                );
                if (result == true) {
                  _refreshUsers();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.black),
              title: Text('Delete User', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(user);
              },
            ),
            // Additional options
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.black),
              title: Text('User Details', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(ctx);
                // Implement detailed view if needed
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete User',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Are you sure you want to delete ${user.username}?',
              style: GoogleFonts.poppins(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete),
            label: Text(
              'Delete',
              style: GoogleFonts.poppins(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Deleting user...',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              
              final success = await _apiService.deleteUser(user.id!);
              
              // Close loading dialog
              Navigator.of(context).pop();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(10),
                  ),
                );
                _refreshUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete user'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(10),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}