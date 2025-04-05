class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String brand;
  final List<String> availableColors;
  final List<double> availableSizes;
  final bool isNewArrival;
  final double popularity;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.brand,
    required this.availableColors,
    required this.availableSizes,
    required this.isNewArrival,
    this.popularity = 0,
    this.reviews = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      images: List<String>.from(json['images']),
      brand: json['brand'],
      availableColors: List<String>.from(json['availableColors']),
      availableSizes: List<double>.from(json['availableSizes']),
      isNewArrival: json['isNewArrival'],
      popularity: json['popularity'].toDouble(),
      reviews: json['reviews'] != null
          ? List<Review>.from(
              json['reviews'].map((x) => Review.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'brand': brand,
      'availableColors': availableColors,
      'availableSizes': availableSizes,
      'isNewArrival': isNewArrival,
      'popularity': popularity,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}

class Review {
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userName: json['userName'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}

