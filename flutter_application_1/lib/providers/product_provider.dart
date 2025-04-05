import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoes_app/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  String _searchQuery = '';
  String _selectedBrand = 'All';
  List<String> _brands = ['All'];

  double _minPrice = 0;
  double _maxPrice = 1000;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 1000;

  String _sortBy = 'Default';
  final List<String> _sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Popularity',
    'New Arrivals'
  ];

  bool _isLoading = true;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  List<String> get brands => _brands;
  String get selectedBrand => _selectedBrand;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  double get selectedMinPrice => _selectedMinPrice;
  double get selectedMaxPrice => _selectedMaxPrice;
  String get sortBy => _sortBy;
  List<String> get sortOptions => _sortOptions;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // Fallback image in case of missing images
    const fallbackImage = 'https://placehold.co/400x400/png?text=Shoe';
    
    try {
      debugPrint('Attempting to load products from JSON file');
      
      // Load from local assets
      final String response = await rootBundle.loadString('assets/images/products.json');
      debugPrint('JSON loaded successfully, content length: ${response.length}');
      
      final data = await json.decode(response);
      debugPrint('JSON decoded successfully, products count: ${data['products'].length}');
      
      // Parse products and ensure each product has fallback images
      _products = List<Product>.from(data['products'].map((x) {
        Product product = Product.fromJson(x);
        
        // Ensure each product has at least one image
        List<String> images = List<String>.from(product.images);
        if (images.isEmpty) {
          images.add(fallbackImage);
        }
        
        // Add fallback image as secondary option
        if (!images.contains(fallbackImage)) {
          images.add(fallbackImage);
        }
        
        // Create new product with updated images
        return Product(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          images: images,
          brand: product.brand,
          availableColors: product.availableColors,
          availableSizes: product.availableSizes,
          isNewArrival: product.isNewArrival,
          popularity: product.popularity,
          reviews: product.reviews,
        );
      }));
      
      _filteredProducts = List.from(_products);
      
      debugPrint('Products parsed, count: ${_products.length}');
      
      // Extract all unique brands
      Set<String> brandSet = {'All'};
      for (var product in _products) {
        brandSet.add(product.brand);
      }
      _brands = brandSet.toList();
      
      // Find min and max prices
      if (_products.isNotEmpty) {
        _minPrice = _products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
        _maxPrice = _products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
        _selectedMinPrice = _minPrice;
        _selectedMaxPrice = _maxPrice;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
      _errorMessage = 'Failed to load products: $e';
      
      // Use mock data if JSON loading fails
      debugPrint('Using mock data instead');
      _products = _getMockProducts();
      _filteredProducts = List.from(_products);
      
      // Extract brands from mock data
      Set<String> brandSet = {'All'};
      for (var product in _products) {
        brandSet.add(product.brand);
      }
      _brands = brandSet.toList();
      
      // Set price range
      _minPrice = 50;
      _maxPrice = 250;
      _selectedMinPrice = _minPrice;
      _selectedMaxPrice = _maxPrice;
      
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilters();
  }

  void setBrand(String brand) {
    _selectedBrand = brand;
    applyFilters();
  }

  void setPriceRange(double min, double max) {
    _selectedMinPrice = min;
    _selectedMaxPrice = max;
    applyFilters();
  }

  void setSortOption(String option) {
    _sortBy = option;
    applyFilters();
  }

  void applyFilters() {
    _filteredProducts = _products.where((product) {
      // Apply brand filter
      if (_selectedBrand != 'All' && product.brand != _selectedBrand) {
        return false;
      }

      // Apply price range filter
      if (product.price < _selectedMinPrice ||
          product.price > _selectedMaxPrice) {
        return false;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !product.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) &&
          !product.brand.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Price: Low to High':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Popularity':
        _filteredProducts.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      case 'New Arrivals':
        _filteredProducts.sort((a, b) => b.isNewArrival ? 1 : -1);
        break;
      default:
        // Default sorting
        break;
    }

    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void addReview(int productId, Review review) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      final product = _products[productIndex];
      final reviewsList = List<Review>.from(product.reviews);
      reviewsList.add(review);

      // Create updated product with new review
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        images: product.images,
        brand: product.brand,
        availableColors: product.availableColors,
        availableSizes: product.availableSizes,
        isNewArrival: product.isNewArrival,
        popularity: product.popularity,
        reviews: reviewsList,
      );

      // Update the products list
      _products[productIndex] = updatedProduct;

      // Also update in filtered products if present
      final filteredIndex =
          _filteredProducts.indexWhere((p) => p.id == productId);
      if (filteredIndex != -1) {
        _filteredProducts[filteredIndex] = updatedProduct;
      }

      notifyListeners();
    }
  }

  // Mock data with more reliable image URLs
  List<Product> _getMockProducts() {
    debugPrint('Generating mock product data');
    
    // More reliable placeholder image
    const fallbackImage = 'https://placehold.co/400x400/png?text=Shoe';
    
    return [
      Product(
        id: 1,
        name: 'Air Max 90',
        description: 'The Nike Air Max 90 stays true to its OG running roots with the iconic Waffle outsole, stitched overlays and classic TPU details.',
        price: 120.00,
        images: [
          'https://picsum.photos/400/400?random=1',
          fallbackImage
        ],
        brand: 'Nike',
        availableColors: ['White', 'Black', 'Red'],
        availableSizes: [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0],
        isNewArrival: false,
        popularity: 4.7,
        reviews: [
          Review(
            userName: 'JohnD',
            rating: 5.0,
            comment: 'Great shoes! Very comfortable for all-day wear.',
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
      ),
      Product(
        id: 2,
        name: 'Ultraboost 22',
        description: 'Responsive shoes built for a smooth, energized ride. The adidas Ultraboost 22 delivers incredible comfort and energy return.',
        price: 180.00,
        images: [
          'https://picsum.photos/400/400?random=2',
          fallbackImage
        ],
        brand: 'Adidas',
        availableColors: ['Black', 'White', 'Blue'],
        availableSizes: [7.0, 8.0, 9.0, 10.0, 11.0, 12.0],
        isNewArrival: true,
        popularity: 4.8,
        reviews: [
          Review(
            userName: 'RunnerPro',
            rating: 5.0,
            comment: 'Best running shoes I\'ve ever owned. Great support.',
            date: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
      ),
      Product(
        id: 3,
        name: 'Chuck Taylor All Star',
        description: 'The Converse Chuck Taylor All Star is the iconic sneaker that started it all.',
        price: 55.00,
        images: [
          'https://picsum.photos/400/400?random=3',
          fallbackImage
        ],
        brand: 'Converse',
        availableColors: ['Black', 'White', 'Red', 'Navy'],
        availableSizes: [5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0],
        isNewArrival: false,
        popularity: 4.5,
        reviews: [],
      ),
      Product(
        id: 4,
        name: 'Classic Leather',
        description: 'The Reebok Classic Leather features a soft leather upper, iconic silhouette and classic details.',
        price: 75.00,
        images: [
          'https://picsum.photos/400/400?random=4',
          fallbackImage
        ],
        brand: 'Reebok',
        availableColors: ['White', 'Black', 'Gray'],
        availableSizes: [7.0, 8.0, 9.0, 10.0, 11.0],
        isNewArrival: false,
        popularity: 4.3,
        reviews: [],
      ),
      Product(
        id: 5,
        name: 'Old Skool',
        description: 'The Vans Old Skool is a classic skate shoe with the famous side stripe design.',
        price: 65.00,
        images: [
          'https://picsum.photos/400/400?random=5',
          fallbackImage
        ],
        brand: 'Vans',
        availableColors: ['Black/White', 'Navy', 'Red'],
        availableSizes: [6.0, 7.0, 8.0, 9.0, 10.0, 11.0],
        isNewArrival: false,
        popularity: 4.6,
        reviews: [],
      ),
      Product(
        id: 6,
        name: 'RS-X',
        description: 'The PUMA RS-X reinvents the classic RS running system with bold color combinations.',
        price: 110.00,
        images: [
          'https://picsum.photos/400/400?random=6',
          fallbackImage
        ],
        brand: 'PUMA',
        availableColors: ['White/Blue', 'Black/Red', 'Gray/Yellow'],
        availableSizes: [7.0, 8.0, 9.0, 10.0, 11.0, 12.0],
        isNewArrival: true,
        popularity: 4.4,
        reviews: [],
      ),
    ];
  }
}
