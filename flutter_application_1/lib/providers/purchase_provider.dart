import 'package:flutter/material.dart';
import 'package:shoes_app/models/order_model.dart';
import 'package:shoes_app/models/product_model.dart';
import 'package:shoes_app/providers/cart_provider.dart';

class PurchaseProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  // Place an order with the items in the cart
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

    notifyListeners();
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

  // Get order details
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
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
    notifyListeners();
  }
}
