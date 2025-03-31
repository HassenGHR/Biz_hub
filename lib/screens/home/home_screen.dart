// lib/screens/home/home_screen.dart
import 'package:biz_hub/screens/company/companies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../widgets/company_card.dart';
import '../../models/company.dart';
import '../../services/comapny_service.dart';
import 'menu/menu_screen.dart';
import 'notifications/notifications_screen.dart';
import '../tools/tools_dashboard_screen.dart';
import '../company/edit_comapny_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final CompanyService _companyService = CompanyService();
  final TextEditingController _searchController = TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State variables
  List<Company> _featuredCompanies = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showSearchBar = false;

  // Scroll controller
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Listen to scroll to handle app bar appearance
    _scrollController.addListener(_listenToScrollChange);

    // Load data
    _loadFeaturedCompanies();

    // Start animation after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 70) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await _companyService.getCompanies();

      setState(() {
        _featuredCompanies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading featured companies: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accentColor2,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _loadFeaturedCompanies,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  automaticallyImplyLeading: false,
                  pinned: true,
                  elevation: _isScrolled ? 4 : 0,
                  titleSpacing: 0,
                  expandedHeight: 70,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  title: AnimatedOpacity(
                    duration: AppDurations.short,
                    opacity: _isScrolled ? 1.0 : 0.0,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Hero(
                          tag: 'app_logo',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              'BizHub',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'app_logo_expanded',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    'BizHub',
                                    style:
                                        theme.textTheme.displaySmall?.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.notifications),
                                onPressed: () {
                                  AppRoutes.navigateTo(
                                      context, AppRoutes.notifications);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFeaturedCompanies,
                      color: AppColors.primaryColor,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting Section
                            _buildGreetingSection(),

                            const SizedBox(height: 24),

                            // Ads Section
                            _buildAdsSection(),

                            const SizedBox(height: 24),

                            // Quick Actions Section
                            _buildQuickActionsSection(),

                            const SizedBox(height: 24),

                            // Featured Companies Section
                            _buildFeaturedCompaniesSection(),

                            const SizedBox(height: 24),

                            // Popular Categories Section
                            _buildPopularCategoriesSection(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
          elevation: 8,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: theme.hintColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Companies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    String _getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning';
      } else if (hour < 17) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
      }
    }

    return NeumorphicContainer(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover businesses in your area',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsSection() {
    return GlassmorphicContainer(
      borderRadius: 16,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.business,
                size: 100,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promote Your Business',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get noticed by thousands of potential customers in your area',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to promotion page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Start Promoting'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionItem(
              'Resume Builder',
              Icons.description,
              AppColors.primaryColor,
              () {
                Navigator.pushNamed(context, AppRoutes.resumeBuilder);
              },
            ),
            _buildQuickActionItem(
              'Scan Card',
              Icons.credit_card,
              AppColors.accentColor1,
              () {
                // Navigator.pushNamed(context, AppRoutes.cardScanner);
              },
            ),
            _buildQuickActionItem(
              'Extract Text',
              Icons.text_fields,
              AppColors.accentColor2,
              () {
                // Navigator.pushNamed(context, AppRoutes.textExtraction);
              },
            ),
            _buildQuickActionItem(
              'Add Business',
              Icons.add_business,
              AppColors.accentColor2,
              () {
                Navigator.pushNamed(context, AppRoutes.addCompany);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCompaniesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Companies',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigator.pushNamed(context, AppRoutes.companies);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _featuredCompanies.isEmpty
            ? _buildEmptyFeaturedCompanies()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _featuredCompanies.length > 3
                    ? 3
                    : _featuredCompanies.length,
                itemBuilder: (context, index) {
                  final company = _featuredCompanies[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: StaggeredAnimationItem(
                      index: index,
                      child: CompanyCard(company: company),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyFeaturedCompanies() {
    return NeumorphicContainer(
      child: Column(
        children: [
          Icon(
            Icons.business,
            size: 48,
            color: AppColors.neutralMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'No featured companies yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to add your business',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutralMedium,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addCompany);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Company'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCategoriesSection() {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Restaurants',
        'icon': Icons.restaurant,
        'color': Colors.orange,
      },
      {
        'name': 'Shopping',
        'icon': Icons.shopping_bag,
        'color': Colors.blue,
      },
      {
        'name': 'Services',
        'icon': Icons.build,
        'color': Colors.green,
      },
      {
        'name': 'Healthcare',
        'icon': Icons.local_hospital,
        'color': Colors.red,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                // Navigator.pushNamed(
                //   context,
                //   AppRoutes.,
                //   arguments: {'category': category['name']},
                // );
              },
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: category['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        category['icon'],
                        color: category['color'],
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;

    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });

    // Navigate based on index
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Tools
        Navigator.push(
          context,
          _createPageRoute(const ToolsDashboardScreen()),
        );
        break;
      case 2: // Add Company
        Navigator.push(
          context,
          _createPageRoute(const CompanyFormScreen()),
        );
        break;
      case 3: // Notifications
        Navigator.push(
          context,
          _createPageRoute(const CompaniesScreen()),
        );
        break;
      case 4: // Menu
        Navigator.push(
          context,
          _createPageRoute(const MenuScreen()),
        );
        break;
    }
  }

  // Helper method to create consistent page routes
  PageRoute _createPageRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: AppDurations.medium,
    );
  }
}

// Staggered animation list item
class StaggeredAnimationItem extends StatelessWidget {
  final Widget child;
  final int index;
  final bool animate;

  const StaggeredAnimationItem({
    Key? key,
    required this.child,
    required this.index,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return animate
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: child,
          )
        : child;
  }
}

// Glass morphic container
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final Color borderColor;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.blur = 10.0,
    this.borderColor = Colors.white30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: isDark
            ? ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur)
            : ui.ImageFilter.blur(sigmaX: blur / 2, sigmaY: blur / 2),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.glassGradient,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// Neumorphic container
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black54,
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.grey.shade800,
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(5, 5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(-5, -5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}

// Custom animation durations
class AppDurations {
  static const Duration shortest = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration long = Duration(milliseconds: 500);
}
