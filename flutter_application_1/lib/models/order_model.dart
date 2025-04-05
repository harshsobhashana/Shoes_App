import 'package:shoes_app/models/cart_item_model.dart';
import 'package:shoes_app/models/product_model.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned
}

class OrderItem {
  final int id;
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final double price;
  final DateTime orderDate;
  final String orderStatus;

  OrderItem({
    required this.id,
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    required this.orderDate,
    required this.orderStatus,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
      'orderDate': orderDate.toIso8601String(),
      'orderStatus': orderStatus,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'],
      price: json['price'],
      orderDate: DateTime.parse(json['orderDate']),
      orderStatus: json['orderStatus'],
    );
  }
}

class Order {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String orderStatus;
  final String paymentMethod;
  final String shippingAddress;
  final DateTime? deliveryDate;

  Order({
    required this.orderId,
    this.userId = '',
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.orderStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    this.deliveryDate,
  });
  
  String get id => orderId;
  OrderStatus get status => _stringToOrderStatus(orderStatus);
  
  Order copyWith({
    String? orderId,
    String? userId,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    String? orderStatus,
    String? paymentMethod,
    String? shippingAddress,
    DateTime? deliveryDate,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'deliveryDate': deliveryDate?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      userId: json['userId'] ?? '',
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'],
      orderDate: DateTime.parse(json['orderDate']),
      orderStatus: json['orderStatus'],
      paymentMethod: json['paymentMethod'],
      shippingAddress: json['shippingAddress'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }
  
  OrderStatus _stringToOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String shippingAddressId;
  final OrderStatus status;
  final String? trackingNumber;
  final DateTime? deliveryDate;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.shippingAddressId,
    this.status = OrderStatus.pending,
    this.trackingNumber,
    this.deliveryDate,
  });

  OrderModel copyWith({
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    String? shippingAddressId,
    OrderStatus? status,
    String? trackingNumber,
    DateTime? deliveryDate,
  }) {
    return OrderModel(
      id: this.id,
      userId: this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      shippingAddressId: shippingAddressId ?? this.shippingAddressId,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddressId': shippingAddressId,
      'status': status.toString().split('.').last,
      'trackingNumber': trackingNumber,
      'deliveryDate': deliveryDate?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'],
      orderDate: DateTime.parse(json['orderDate']),
      shippingAddressId: json['shippingAddressId'],
      status: OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      trackingNumber: json['trackingNumber'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }

  String get statusText {
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
      default:
        return 'Unknown';
    }
  }
}
