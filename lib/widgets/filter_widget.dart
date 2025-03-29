import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final String? searchQuery;
  final double? radius;
  final Function(String?, String?, double?) onFilterApplied;

  const FilterWidget({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.searchQuery,
    this.radius,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late String? _selectedCategory;
  late TextEditingController _searchController;
  late double _radius;
  final double _minRadius = 1.0;
  final double _maxRadius = 50.0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _radius = widget.radius ?? 10.0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Businesses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),

          // Search field
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search by name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),

          // Category dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            hint: const Text('Select a category'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Categories'),
              ),
              ...widget.categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 16.0),

          // Radius slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance: ${_radius.round()} km',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _radius,
                min: _minRadius,
                max: _maxRadius,
                divisions: (_maxRadius - _minRadius).round(),
                label: '${_radius.round()} km',
                onChanged: (double value) {
                  setState(() {
                    _radius = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Reset all filters
                  setState(() {
                    _selectedCategory = null;
                    _searchController.clear();
                    _radius = 10.0;
                  });
                },
                child: const Text('RESET'),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Apply filters
                  widget.onFilterApplied(
                    _selectedCategory,
                    _searchController.text.isEmpty
                        ? null
                        : _searchController.text,
                    _radius,
                  );
                  Navigator.pop(context);
                },
                child: const Text('APPLY'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
