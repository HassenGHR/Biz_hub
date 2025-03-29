import 'package:biz_hub/models/company.dart';
import 'package:biz_hub/screens/profile/user_profile_screen.dart';
import 'package:biz_hub/screens/tools/tools_dashboard_screen.dart';
import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/widgets/company_card.dart';
import 'package:biz_hub/widgets/filter_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CompanyService _companyService = CompanyService();
  final TextEditingController _searchController = TextEditingController();
  List<Company> _companies = [];
  List<Company> _filteredCompanies = [];
  String _currentCategory = 'All';
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _searchController.addListener(_filterCompanies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await _companyService.getCompanies();
      setState(() {
        _companies = companies;
        _filteredCompanies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading companies: ${e.toString()}')),
      );
    }
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
    });
    _filterCompanies();
  }

  // Handle filter application with price range and rating
  void _onFilterApplied(String? category, String? sortBy, double? minRating) {
    setState(() {
      if (category != null) {
        _currentCategory = category;
      }
    });

    // Apply additional filtering based on rating if provided
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

      // Apply sorting if specified
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BizHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompanies,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for companies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterCompanies();
                  },
                ),
              ),
            ),
          ),
          FilterWidget(
            categories: [
              'All',
              'Technology',
              'Retail',
              'Healthcare',
              'Food',
              'Services'
            ],
            selectedCategory: _currentCategory,
            // onCategorySelected: _selectCategory,
            onFilterApplied: _onFilterApplied, // Implemented callback
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCompanies.isEmpty
                    ? const Center(child: Text('No companies found'))
                    : RefreshIndicator(
                        onRefresh: _loadCompanies,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _filteredCompanies.length,
                          itemBuilder: (context, index) {
                            final company = _filteredCompanies[index];
                            return CompanyCard(
                              company: company,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-company');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new company',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ToolsDashboardScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                        userId: '',
                      )),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            // Fixed from BottomNavigationBar.item
            icon: Icon(Icons.business),
            label: 'Companies',
          ),
          BottomNavigationBarItem(
            // Fixed from BottomNavigationBar.item
            icon: Icon(Icons.build),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            // Fixed from BottomNavigationBar.item
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
