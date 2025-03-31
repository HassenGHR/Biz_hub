import 'package:biz_hub/config/routes.dart';
import 'package:biz_hub/config/theme.dart';
import 'package:biz_hub/models/company.dart';
import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/widgets/company_card.dart';
import 'package:biz_hub/widgets/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class CompaniesScreen extends StatefulWidget {
  final String? initialCategory;

  const CompaniesScreen({
    Key? key,
    this.initialCategory,
  }) : super(key: key);

  @override
  _CompaniesScreenState createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen>
    with TickerProviderStateMixin {
  final CompanyService _companyService = CompanyService();
  final TextEditingController _searchController = TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State variables
  List<Company> _companies = [];
  List<Company> _filteredCompanies = [];
  String _currentCategory = 'All';
  bool _isLoading = true;
  bool _showSearchBar = false;

  List<String> _categories = [];

  // Scroll controller for handling app bar collapse
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
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

    // Set initial category if provided
    if (widget.initialCategory != null) {
      _currentCategory = widget.initialCategory!;
    }

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
    _searchController.dispose();
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies({String? selectedCategory}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use provided category or previously set category
      if (selectedCategory != null) {
        _currentCategory = selectedCategory;
      }

      _categories = await CompanyService().getCategories();
      _categories.insert(0, "All"); // Add "All" as the first option

      final companies = await _companyService.getCompanies();

      setState(() {
        _companies = companies;

        // Apply category filter
        _filteredCompanies = (_currentCategory == "All")
            ? companies
            : companies
                .where((company) => company.category == _currentCategory)
                .toList();

        _isLoading = false;
      });

      // Scroll to selected category after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCategoryIfNeeded();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading companies: ${e.toString()}');
    }
  }

  void _scrollToCategoryIfNeeded() {
    if (_currentCategory != 'All' && _categoryScrollController.hasClients) {
      final index = _categories.indexOf(_currentCategory);
      if (index > 0) {
        // Approximate position calculation
        final estimatedPosition = (index * 120.0) - 100;
        _categoryScrollController.animateTo(
          estimatedPosition > 0 ? estimatedPosition : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
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
    if (category == _currentCategory) return;

    setState(() {
      _currentCategory = category;
    });
    _filterCompanies();

    // Add haptic feedback
    HapticFeedback.selectionClick();

    // Delay scrolling to ensure UI is updated
    Future.delayed(const Duration(milliseconds: 50), () {
      _scrollToCategoryIfNeeded();
    });
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
    final childAspectRatio = isMobile ? 3.0 : 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Companies',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
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
              setState(() {
                _currentCategory = "All";
                _selectCategory(_currentCategory);
              });
              _loadCompanies();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              if (_showSearchBar)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for companies...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
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
              Container(
                height: 48,
                color: theme.scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => _selectCategory(category),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: _currentCategory == category
                                  ? AppColors.primaryColor.withOpacity(0.1)
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _currentCategory == category
                                    ? AppColors.primaryColor
                                    : theme.hintColor,
                                fontWeight: _currentCategory == category
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
              ),
            ],
          ),
        ),
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredCompanies.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadCompanies,
                    color: AppColors.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
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
                          padding: const EdgeInsets.only(bottom: 10),
                          itemBuilder: (context, index) {
                            final company = _filteredCompanies[index];
                            return _buildAnimatedCompanyItem(index, company);
                          },
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.addCompany);
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_business, color: Colors.white),
      ),
    );
  }

  Widget _buildAnimatedCompanyItem(int index, Company company) {
    return TweenAnimationBuilder<double>(
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
      child: Hero(
        tag: 'company_${company.id}',
        child: Material(
          type: MaterialType.transparency,
          child: CompanyCard(company: company),
        ),
      ),
    );
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _searchController.text.isNotEmpty || _currentCategory != 'All'
                  ? 'Try changing your search or filters'
                  : 'Add a new company to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutralMedium,
                  ),
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
