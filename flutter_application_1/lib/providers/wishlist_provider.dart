import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoes_app/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _items = [];
  
  List<Product> get items => _items;
  
  int get itemCount => _items.length;
  
  bool isInWishlist(Product product) {
    return _items.any((item) => item.id == product.id);
  }
  
  WishlistProvider() {
    loadWishlist();
  }
  
  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = prefs.getString('wishlist');
      
      if (wishlistData != null) {
        // In a real app, you'd need to properly deserialize the products
        // Here we're just initializing an empty wishlist for simplicity
        _items = [];
        notifyListeners();
      }
    } catch (e) {
      _items = [];
    }
  }
  
  Future<void> saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // In a real app, you might store product IDs instead of the full objects
      final productIds = _items.map((product) => product.id).toList();
      final wishlistData = json.encode(productIds);
      
      await prefs.setString('wishlist', wishlistData);
    } catch (e) {
      // Handle error
    }
  }
  
  void toggleWishlist(Product product) {
    final isExist = _items.any((item) => item.id == product.id);
    
    if (isExist) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }
    
    saveWishlist();
    notifyListeners();
  }
  
  void addToWishlist(Product product) {
    if (!isInWishlist(product)) {
      _items.add(product);
      saveWishlist();
      notifyListeners();
    }
  }
  
  void removeFromWishlist(Product product) {
    _items.removeWhere((item) => item.id == product.id);
    saveWishlist();
    notifyListeners();
  }
  
  void clearWishlist() {
    _items = [];
    saveWishlist();
    notifyListeners();
  }
}

