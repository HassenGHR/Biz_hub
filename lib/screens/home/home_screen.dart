import 'package:biz_hub/config/routes.dart';
import 'package:biz_hub/config/theme.dart';
import 'package:biz_hub/models/company.dart';
import 'package:biz_hub/models/user.dart';
import 'package:biz_hub/screens/company/add_comapny_screen.dart';
import 'package:biz_hub/screens/home/menu/menu_screen.dart';
import 'package:biz_hub/screens/home/notifications/notifications_screen.dart';
import 'package:biz_hub/screens/profile/user_profile_screen.dart';
import 'package:biz_hub/screens/tools/tools_dashboard_screen.dart';
import 'package:biz_hub/services/auth_service.dart';
import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/services/user_service.dart';
import 'package:biz_hub/widgets/company_card.dart';
import 'package:biz_hub/widgets/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

// Define app theme and colors in a separate file, imported here

// Custom animation durations
class AppDurations {
  static const Duration shortest = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration long = Duration(milliseconds: 500);
}

// Custom widgets
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

// Neumorphic container effect
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

// Main HomeScreen implementation
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

  // Tab controller for category selection
  late TabController _tabController;

  // State variables
  List<Company> _companies = [];
  List<Company> _filteredCompanies = [];
  String _currentCategory = 'All';
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showSearchBar = false;
  final List<String> _categories = [
    'All',
    'Technology',
    'Retail',
    'Healthcare',
    'Food',
    'Services'
  ];

  // Scroll controller for handling app bar collapse
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

    // Initialize tab controller
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
        _selectCategory(_categories[_tabController.index]);
      }
    });

    // Listen to scroll to handle app bar appearance
    _scrollController.addListener(_listenToScrollChange);

    // Load data
    _loadCompanies();
    _searchController.addListener(_filterCompanies);

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
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await _companyService.getCompanies();

      print("len:----------------------${companies.length}");
      setState(() {
        _companies = companies;
        _filteredCompanies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading companies: ${e.toString()}');
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
          onPressed: _loadCompanies,
        ),
      ),
    );
  }

  void _filterCompanies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCompanies = _companies.where((company) {
        final nameMatch = company.name.toLowerCase().contains(query);
        final categoryMatch =
            _currentCategory == 'All' || company.category == _currentCategory;
        return nameMatch && categoryMatch;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _currentCategory = category;
      _tabController.index = _categories.indexOf(category);
    });
    _filterCompanies();
  }

  void _onFilterApplied(String? category, String? sortBy, double? minRating) {
    if (category != null && category != _currentCategory) {
      _selectCategory(category);
    }

    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCompanies = _companies.where((company) {
        final nameMatch = company.name.toLowerCase().contains(query);
        final categoryMatch =
            _currentCategory == 'All' || company.category == _currentCategory;
        final ratingMatch =
            minRating == null || (company.ratings ?? 0) >= minRating;
        return nameMatch && categoryMatch && ratingMatch;
      }).toList();

      if (sortBy == 'rating') {
        _filteredCompanies
            .sort((a, b) => (b.ratings ?? 0).compareTo(a.ratings ?? 0));
      } else if (sortBy == 'name') {
        _filteredCompanies.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Responsive breakpoints
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 900;

    // Grid settings based on screen size
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    final childAspectRatio = isMobile ? 1.2 : 1.0;

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
                  pinned: true,
                  elevation: _isScrolled ? 4 : 0,
                  titleSpacing: 0,
                  expandedHeight: 140,
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
                        const Spacer(),
                        AnimatedContainer(
                          duration: AppDurations.short,
                          width: _showSearchBar && _isScrolled ? 200 : 0,
                          child: _showSearchBar && _isScrolled
                              ? TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: TextStyle(fontSize: 14),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        IconButton(
                          icon: Icon(_showSearchBar && _isScrolled
                              ? Icons.close
                              : Icons.search),
                          onPressed: () {
                            setState(() {
                              _showSearchBar = !_showSearchBar;
                            });
                            HapticFeedback.selectionClick();
                          },
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
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    _showSearchBar = true;
                                  });
                                  HapticFeedback.selectionClick();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  _showFilterBottomSheet();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _loadCompanies();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_isScrolled && _showSearchBar)
                          AnimatedContainer(
                            duration: AppDurations.short,
                            height: _showSearchBar ? 56 : 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GlassmorphicContainer(
                              borderRadius: 30,
                              padding: EdgeInsets.zero,
                              blur: 5,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search for companies...',
                                  prefixIcon: const Icon(Icons.search,
                                      color: AppColors.primaryColor),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear),
                                    color: AppColors.neutralMedium,
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterCompanies();
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                        color: theme.scaffoldBackgroundColor,
                        child:
                            // Replace the TabBar in your code with this horizontal scrollable list of category containers
                            Container(
                          height: 48,
                          color: theme.scaffoldBackgroundColor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: _categories.map((category) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _currentCategory = category;
                                      });
                                      // Add any additional logic needed when category changes
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: _currentCategory == category
                                            ? AppColors.primaryColor
                                                .withOpacity(0.1)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _currentCategory == category
                                              ? AppColors.primaryColor
                                              : theme.dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: _currentCategory == category
                                              ? AppColors.primaryColor
                                              : theme.hintColor,
                                          fontWeight:
                                              _currentCategory == category
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )),
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
                  : _filteredCompanies.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadCompanies,
                          color: AppColors.primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AnimatedSwitcher(
                              duration: AppDurations.medium,
                              child: GridView.builder(
                                key: ValueKey<String>(_currentCategory),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _filteredCompanies.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 100),
                                itemBuilder: (context, index) {
                                  final company = _filteredCompanies[index];
                                  return StaggeredAnimationItem(
                                    index: index,
                                    child: Hero(
                                      tag: 'company_${company.id}',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: CompanyCard(
                                          company: company,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ),
      ),
      // floatingActionButton: AnimatedContainer(
      //   duration: AppDurations.medium,
      //   curve: Curves.easeInOut,
      //   transform: Matrix4.translationValues(
      //     0,
      //     _isScrolled ? 0 : 20,
      //     0,
      //   ),
      //   child: FloatingActionButton.extended(
      //     onPressed: () {
      //       HapticFeedback.mediumImpact();
      //       Navigator.pushNamed(context, '/add-company');
      //     },
      //     icon: const Icon(Icons.add),
      //     label: const Text('Add Company'),
      //     elevation: 1,
      //     backgroundColor: AppColors.primaryColor,
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8.0,
        color: theme.colorScheme.surface,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.build, 'Tools'),
              _buildNavItem(2, Icons.add, 'Add'),
              _buildNavItem(3, Icons.notifications, 'Notifications'),
              _buildNavItem(4, Icons.menu, 'Menu'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _onNavItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryColor.withOpacity(0.1),
      highlightColor: AppColors.primaryColor.withOpacity(0.05),
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : theme.hintColor,
              size: 20, // Slightly smaller icon
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryColor : theme.hintColor,
                fontSize: 11, // Slightly smaller text
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;

    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ToolsDashboardScreen(),
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
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AddCompanyScreen(),
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
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const NotificationsScreen(),
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
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MenuScreen(),
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
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: AppColors.neutralMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'No companies found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _currentCategory != 'All'
                ? 'Try changing your search or filters'
                : 'Add a new company to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutralMedium,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_searchController.text.isNotEmpty ||
                  _currentCategory != 'All') {
                _searchController.clear();
                _selectCategory('All');
              } else {
                AppRoutes.navigateTo(context, AppRoutes.addCompany);
              }
            },
            icon: Icon(
              _searchController.text.isNotEmpty || _currentCategory != 'All'
                  ? Icons.clear_all
                  : Icons.add_business,
            ),
            label: Text(
              _searchController.text.isNotEmpty || _currentCategory != 'All'
                  ? 'Clear filters'
                  : 'Add company',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return FilterWidget(
            categories: _categories,
            currentCategory: _currentCategory,
            onApply: _onFilterApplied,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}
