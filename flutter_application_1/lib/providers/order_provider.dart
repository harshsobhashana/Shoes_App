import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoes_app/models/cart_item_model.dart';
import 'package:shoes_app/models/order_model.dart';
import 'package:shoes_app/models/product_model.dart';
import 'package:shoes_app/providers/cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _loadOrdersFromPrefs();
  }

  Future<void> _loadOrdersFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final ordersData = prefs.getString('orders_data');

    if (ordersData != null) {
      try {
        final List<dynamic> ordersJson = jsonDecode(ordersData);
        _orders =
            ordersJson.map((orderJson) => Order.fromJson(orderJson)).toList();
      } catch (e) {
        debugPrint('Error loading orders data: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveOrdersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersData =
        jsonEncode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString('orders_data', ordersData);
  }

  // Get orders for a specific user
  List<Order> getOrdersForUser(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Place a new order
  void placeOrder({
    required CartProvider cartProvider,
    required String paymentMethod,
    required String shippingAddress,
  }) {
    if (cartProvider.items.isEmpty) return;

    // Generate a unique order ID
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final orderDate = DateTime.now();

    // Convert cart items to order items
    final List<OrderItem> orderItems = cartProvider.items.map((cartItem) {
      return OrderItem(
        id: cartItem.product.id,
        product: cartItem.product,
        size: cartItem.size,
        color: cartItem.color,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
        orderDate: orderDate,
        orderStatus: 'Processing',
      );
    }).toList();

    // Calculate total amount
    final totalAmount = cartProvider.totalPrice;

    // Create new order
    final newOrder = Order(
      orderId: orderId,
      items: orderItems,
      totalAmount: totalAmount,
      orderDate: orderDate,
      orderStatus: 'Processing',
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
    );

    // Add to orders list
    _orders.add(newOrder);

    // Clear the cart
    cartProvider.clearCart();

    _saveOrdersToPrefs();
    notifyListeners();
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    // In a real app, this would make an API call
    await Future.delayed(const Duration(seconds: 1));

    int orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1 &&
        _orders[orderIndex].status != OrderStatus.delivered) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        orderStatus: 'Cancelled',
      );
      await _saveOrdersToPrefs();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update order status (for demo admin functionality)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    notifyListeners();

    // In a real app, this would make an API call
    await Future.delayed(const Duration(seconds: 1));

    int orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        orderStatus: _orderStatusToString(newStatus),
        deliveryDate:
            newStatus == OrderStatus.delivered ? DateTime.now() : null,
      );
      await _saveOrdersToPrefs();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  // Get all products in orders
  List<Product> getPurchasedProducts() {
    final Set<Product> uniqueProducts = {};

    for (var order in _orders) {
      for (var item in order.items) {
        uniqueProducts.add(item.product);
      }
    }

    return uniqueProducts.toList();
  }

  // For demo: Add a sample order
  void addSampleOrder(List<Product> products) {
    if (products.isEmpty) return;

    final orderId = 'ORD-SAMPLE-${DateTime.now().millisecondsSinceEpoch}';
    final orderDate = DateTime.now().subtract(const Duration(days: 5));

    // Create sample order items (just first 2 products)
    final List<OrderItem> orderItems = products.take(2).map((product) {
      return OrderItem(
        id: product.id,
        product: product,
        size: product.availableSizes.first.toString(),
        color: product.availableColors.first,
        quantity: 1,
        price: product.price,
        orderDate: orderDate,
        orderStatus: 'Delivered',
      );
    }).toList();

    // Calculate total amount
    final totalAmount = orderItems.fold(
        0.0, (total, item) => total + (item.price * item.quantity));

    // Create sample order
    final sampleOrder = Order(
      orderId: orderId,
      items: orderItems,
      totalAmount: totalAmount,
      orderDate: orderDate,
      orderStatus: 'Delivered',
      paymentMethod: 'Credit Card',
      shippingAddress: '123 Main St, Anytown, ST 12345',
    );

    _orders.add(sampleOrder);
    _saveOrdersToPrefs();
    notifyListeners();
  }
}
