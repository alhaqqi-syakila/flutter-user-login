import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import 'user_form_screen.dart';
import 'user_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<User>> _usersFuture;
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _loadUsers();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      backgroundColor: const Color(0xFF151515),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with app icon and title
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Havault',
                        style: GoogleFonts.raleway(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'User List',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // IconButton(
                      //   icon: Icon(Icons.home, color: Colors.black87),
                      //   tooltip: 'Home',
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      // ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                        onPressed: () async {
                          // Add a nice animation before logout
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => Center(
                                  child: Container(
                                    padding: EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1D1D1D),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF0077EE),
                                              ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Logging out...',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white
                                          ),
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
                ],
              ),
            ),

            // Users count card
            FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: FutureBuilder<List<User>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      int userCount = 0;
                      if (snapshot.hasData) {
                        userCount = snapshot.data!.length;
                      }

                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1D1D1D), Color(0xFF212121)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(1, 49, 49, 49).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Users',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0077EE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              snapshot.hasData ? '$userCount' : '...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Registered accounts',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Main content section
            Expanded(
              child: RefreshIndicator(
                color: Colors.black87,
                onRefresh: _refreshUsers,
                child: FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black87,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          margin: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.black,
                                size: 60,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Error loading users',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: Icon(Icons.refresh),
                                label: Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: _refreshUsers,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return FadeTransition(
                        opacity: _fadeInAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(24),
                              margin: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_off,
                                    color: Colors.grey[400],
                                    size: 80,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No users found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add a new user with the button below',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.person_add),
                                    label: Text('Add First User'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => UserFormScreen(),
                                          transitionsBuilder: (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            const begin = Offset(0.0, 1.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeOutCubic;
                                            var tween = Tween(
                                              begin: begin,
                                              end: end,
                                            ).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation
                                                .drive(tween);
                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                      if (result == true) {
                                        _refreshUsers();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return FadeTransition(
                        opacity: _fadeInAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AnimationLimiter(
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final user = snapshot.data![index];
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1D1D1D),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder:
                                                        (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                        ) => UserDetailsScreen(
                                                          user: user,
                                                        ),
                                                    transitionsBuilder: (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child,
                                                    ) {
                                                      const begin = Offset(
                                                        1.0,
                                                        0.0,
                                                      ); // Start from right
                                                      const end = Offset.zero;
                                                      const curve =
                                                          Curves.easeOutCubic;

                                                      var tween = Tween(
                                                        begin: begin,
                                                        end: end,
                                                      ).chain(
                                                        CurveTween(
                                                          curve: curve,
                                                        ),
                                                      );
                                                      var offsetAnimation =
                                                          animation.drive(
                                                            tween,
                                                          );

                                                      // Add fade transition alongside slide
                                                      return FadeTransition(
                                                        opacity: animation,
                                                        child: SlideTransition(
                                                          position:
                                                              offsetAnimation,
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    transitionDuration:
                                                        Duration(
                                                          milliseconds: 400,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    // User avatar with initials
                                                    Container(
                                                      width: 56,
                                                      height: 56,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF0077EE),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _getInitials(user),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            user.username,
                                                            style: GoogleFonts.raleway(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors
                                                                      .white,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            user.email,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .white.withOpacity(0.7),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          if (user.fullName !=
                                                                  null &&
                                                              user
                                                                  .fullName!
                                                                  .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 4,
                                                                  ),
                                                              child: Text(
                                                                user.fullName!,
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black54,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Action buttons with consistent styling
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _buildActionButton(
                                                          icon: Icons.edit,
                                                          color: Color(
                                                            0xFFEEAF00,
                                                          ),
                                                          tooltip: 'Edit User',
                                                          onPressed: () async {
                                                            final result = await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => UserFormScreen(
                                                                      user:
                                                                          user,
                                                                    ),
                                                              ),
                                                            );
                                                            if (result ==
                                                                true) {
                                                              _refreshUsers();
                                                            }
                                                          },
                                                        ),
                                                        SizedBox(width: 8),
                                                        _buildActionButton(
                                                          icon: Icons.delete,
                                                          color: Color.fromARGB(
                                                            255,
                                                            238,
                                                            0,
                                                            0,
                                                          ),
                                                          tooltip:
                                                              'Delete User',
                                                          onPressed: () {
                                                            _showDeleteConfirmation(
                                                              user,
                                                            );
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        UserFormScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
            if (result == true) {
              _refreshUsers();
            }
          },
          backgroundColor: Color(0xFF0077EE),
          icon: Icon(Icons.person_add, color: Colors.white),
          label: Text(
            'Add User',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
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

  void _showUserOptions(User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sheet handle
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // User header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(user),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            if (user.fullName != null &&
                                user.fullName!.isNotEmpty)
                              Text(
                                user.fullName!,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Options list
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildOptionTile(
                        icon: Icons.edit,
                        title: 'Edit User',
                        color: Color(0xFFEEAF00),
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
                      _buildOptionTile(
                        icon: Icons.delete,
                        title: 'Delete User',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(ctx);
                          _showDeleteConfirmation(user);
                        },
                      ),
                      _buildOptionTile(
                        icon: Icons.info_outline,
                        title: 'User Details',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      UserDetailsScreen(user: user),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                const begin = Offset(
                                  1.0,
                                  0.0,
                                ); // Start from right
                                const end = Offset.zero;
                                const curve = Curves.easeOutCubic;

                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                // Add fade transition alongside slide
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: Duration(milliseconds: 400),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete User',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete ${user.username}?',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.black54)),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete),
                label: Text(
                  'Delete',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) => Center(
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Deleting user...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
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
                        margin: EdgeInsets.all(16),
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
                        margin: EdgeInsets.all(16),
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
