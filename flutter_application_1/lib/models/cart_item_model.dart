import 'package:shoes_app/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String size;
  final String color;

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? size,
    String? color,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      size: json['size'],
      color: json['color'],
    );
  }
}
