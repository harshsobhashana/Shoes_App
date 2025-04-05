import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoes_app/providers/product_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late RangeValues _currentRangeValues;
  
  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    _minPrice = productProvider.minPrice;
    _maxPrice = productProvider.maxPrice;
    _currentRangeValues = RangeValues(
      productProvider.selectedMinPrice,
      productProvider.selectedMaxPrice,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_currentRangeValues.start.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${_currentRangeValues.end.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _currentRangeValues,
            min: _minPrice,
            max: _maxPrice,
            divisions: (_maxPrice - _minPrice).toInt(),
            labels: RangeLabels(
              '\$${_currentRangeValues.start.toInt()}',
              '\$${_currentRangeValues.end.toInt()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final productProvider = Provider.of<ProductProvider>(context, listen: false);
                    productProvider.setPriceRange(
                      _currentRangeValues.start,
                      _currentRangeValues.end,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentRangeValues = RangeValues(_minPrice, _maxPrice);
                    });
                    final productProvider = Provider.of<ProductProvider>(context, listen: false);
                    productProvider.setPriceRange(_minPrice, _maxPrice);
                  },
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

