import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoes_app/models/cart_item_model.dart';
import 'package:shoes_app/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  int get itemCount => _items.length;
  
  double get totalPrice {
    return _items.fold(0, (total, current) => 
      total + (current.product.price * current.quantity));
  }
  
  double get subtotal => totalPrice;
  
  double get tax => totalPrice * 0.07; // 7% tax
  
  double get shipping => totalPrice > 100 ? 0 : 10; // Free shipping over $100
  
  double get grandTotal => subtotal + tax + shipping;
  
  CartProvider() {
    loadCart();
  }
  
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');
      
      if (cartData != null) {
        // This is a simplified version - in a real app, you'd need to properly
        // reconstruct Product objects from cached IDs
        // Here we're just initializing an empty cart
        _items = [];
        notifyListeners();
      }
    } catch (e) {
      _items = [];
    }
  }
  
  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // In a real app, you might store product IDs and quantities
      // instead of the full product objects
      final itemData = _items.map((item) => item.toJson()).toList();
      final cartData = json.encode(itemData);
      
      await prefs.setString('cart', cartData);
    } catch (e) {
      // Handle error
    }
  }
  
  // Check if product is already in cart with same size and color
  bool isInCart(Product product, String size, String color) {
    return _items.any((item) => 
      item.product.id == product.id && 
      item.size == size && 
      item.color == color);
  }
  
  // Add product to cart
  void addToCart(Product product, String size, String color) {
    final existingIndex = _items.indexWhere((item) => 
      item.product.id == product.id && 
      item.size == size && 
      item.color == color);
    
    if (existingIndex >= 0) {
      // Increment quantity of existing item
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
        size: existingItem.size,
        color: existingItem.color,
      );
    } else {
      // Add new item
      _items.add(CartItem(
        product: product,
        quantity: 1,
        size: size,
        color: color,
      ));
    }
    
    saveCart();
    notifyListeners();
  }
  
  // Remove one item from cart
  void removeItem(Product product, String size, String color) {
    final existingIndex = _items.indexWhere((item) => 
      item.product.id == product.id && 
      item.size == size && 
      item.color == color);
    
    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      if (existingItem.quantity > 1) {
        // Reduce quantity
        _items[existingIndex] = CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
          size: existingItem.size,
          color: existingItem.color,
        );
      } else {
        // Remove item completely
        _items.removeAt(existingIndex);
      }
      
      saveCart();
      notifyListeners();
    }
  }
  
  // Remove item completely from cart
  void removeItemCompletely(Product product, String size, String color) {
    _items.removeWhere((item) => 
      item.product.id == product.id && 
      item.size == size && 
      item.color == color);
    
    saveCart();
    notifyListeners();
  }
  
  // Clear cart
  void clearCart() {
    _items = [];
    saveCart();
    notifyListeners();
  }
  
  Future<void> checkout() async {
    // In a real app, you'd send an order to a server
    // Here we'll just clear the cart and simulate an order
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderItems = _items.map((item) => item.toJson()).toList();
      
      // Get existing orders or create a new list
      List<dynamic> existingOrders = [];
      final ordersData = prefs.getString('orders');
      if (ordersData != null) {
        existingOrders = json.decode(ordersData);
      }
      
      // Create a new order
      final newOrder = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': DateTime.now().toIso8601String(),
        'items': orderItems,
        'subtotal': subtotal,
        'tax': tax,
        'shipping': shipping,
        'total': grandTotal,
      };
      
      // Add to orders list
      existingOrders.add(newOrder);
      
      // Save updated orders
      await prefs.setString('orders', json.encode(existingOrders));
      
      // Clear the cart
      clearCart();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

