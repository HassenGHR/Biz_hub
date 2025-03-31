import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterWidget extends StatefulWidget {
  final List<String> categories;
  final String currentCategory;
  final ScrollController scrollController;
  final Function(String?, String?, double?) onApply;

  const FilterWidget({
    Key? key,
    required this.categories,
    required this.currentCategory,
    required this.onApply,
    required this.scrollController,
  }) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late String? _selectedCategory;
  late double _radius;
  String? _sortBy = 'rating';
  double? _minRating;
  bool _isOpen = false;
  bool _hasParking = false;
  bool _hasDelivery = false;

  // Price range filter
  RangeValues _priceRange = const RangeValues(1, 4);

  // Animation controllers
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.currentCategory != 'All' ? widget.currentCategory : null;
    _radius = 10.0;
  }

  String _getPriceRangeText() {
    String result = '';
    for (int i = 0; i < _priceRange.end.round(); i++) {
      result += '₹';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              children: [
                // Category selection
                Text(
                  'Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory =
                              selected ? null : _selectedCategory;
                        });
                        HapticFeedback.selectionClick();
                      },
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: _selectedCategory == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    ...widget.categories
                        .where((category) => category != 'All')
                        .map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                          HapticFeedback.selectionClick();
                        },
                        backgroundColor:
                            isDark ? Colors.grey[800] : Colors.grey[200],
                        selectedColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: _selectedCategory == category
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ],
                ),

                const SizedBox(height: 24),

                // Sort by
                Text(
                  'Sort by',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Rating'),
                      selected: _sortBy == 'rating',
                      onSelected: (selected) {
                        setState(() {
                          _sortBy = selected ? 'rating' : null;
                        });
                        HapticFeedback.selectionClick();
                      },
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _sortBy == 'rating'
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: _sortBy == 'rating'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Alphabetical'),
                      selected: _sortBy == 'name',
                      onSelected: (selected) {
                        setState(() {
                          _sortBy = selected ? 'name' : null;
                        });
                        HapticFeedback.selectionClick();
                      },
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _sortBy == 'name'
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: _sortBy == 'name'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Distance'),
                      selected: _sortBy == 'distance',
                      onSelected: (selected) {
                        setState(() {
                          _sortBy = selected ? 'distance' : null;
                        });
                        HapticFeedback.selectionClick();
                      },
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _sortBy == 'distance'
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: _sortBy == 'distance'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Rating filter
                Text(
                  'Minimum Rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final rating = index + 1;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _minRating = rating.toDouble();
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color:
                                  (_minRating != null && rating <= _minRating!)
                                      ? theme.colorScheme.primary
                                      : (isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                rating.toString(),
                                style: TextStyle(
                                  color: (_minRating != null &&
                                          rating <= _minRating!)
                                      ? Colors.white
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // Distance filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_radius.round()} km',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor:
                        isDark ? Colors.grey[800] : Colors.grey[300],
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                    trackHeight: 4.0,
                  ),
                  child: Slider(
                    value: _radius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                    onChangeEnd: (_) {
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Price range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price Range',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getPriceRangeText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor:
                        isDark ? Colors.grey[800] : Colors.grey[300],
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                    trackHeight: 4.0,
                  ),
                  child: RangeSlider(
                    values: _priceRange,
                    min: 1,
                    max: 4,
                    divisions: 3,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    onChangeEnd: (_) {
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                // Advanced filters section
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                    HapticFeedback.mediumImpact();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Advanced Filters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded advanced filters
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Currently Open',
                          style: theme.textTheme.bodyLarge,
                        ),
                        value: _isOpen,
                        activeColor: theme.colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _isOpen = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          'Has Parking',
                          style: theme.textTheme.bodyLarge,
                        ),
                        value: _hasParking,
                        activeColor: theme.colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _hasParking = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          'Offers Delivery',
                          style: theme.textTheme.bodyLarge,
                        ),
                        value: _hasDelivery,
                        activeColor: theme.colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _hasDelivery = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ],
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reset all filters
                      setState(() {
                        _selectedCategory = null;
                        _sortBy = 'rating';
                        _minRating = null;
                        _radius = 10.0;
                        _priceRange = const RangeValues(1, 4);
                        _isOpen = false;
                        _hasParking = false;
                        _hasDelivery = false;
                      });
                      HapticFeedback.mediumImpact();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      widget.onApply(
                        _selectedCategory,
                        _sortBy,
                        _minRating,
                      );
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
