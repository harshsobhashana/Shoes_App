import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoes_app/models/product_model.dart';
import 'package:shoes_app/models/product_model.dart' as review_model;
import 'package:shoes_app/providers/cart_provider.dart';
import 'package:shoes_app/providers/product_provider.dart';
import 'package:shoes_app/providers/wishlist_provider.dart';
import 'package:shoes_app/widgets/color_selector.dart';
import 'package:shoes_app/widgets/image_carousel.dart';
import 'package:shoes_app/widgets/review_list.dart';
import 'package:shoes_app/widgets/size_selector.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String _selectedColor;
  late double _selectedSize;
  bool _showReviewForm = false;
  final _reviewTextController = TextEditingController();
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.availableColors.isNotEmpty
        ? widget.product.availableColors[0]
        : '';
    _selectedSize = widget.product.availableSizes.isNotEmpty
        ? widget.product.availableSizes[0]
        : 0.0;
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              wishlistProvider.isInWishlist(widget.product)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: wishlistProvider.isInWishlist(widget.product)
                  ? Colors.red
                  : null,
            ),
            onPressed: () {
              wishlistProvider.toggleWishlist(widget.product);
              _showSnackBar(
                  context,
                  wishlistProvider.isInWishlist(widget.product)
                      ? 'Added to wishlist'
                      : 'Removed from wishlist');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageCarousel(images: widget.product.images),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.brand,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (widget.product.availableColors.isNotEmpty) ...[
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ColorSelector(
                      colors: widget.product.availableColors,
                      selectedColor: _selectedColor,
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.product.availableSizes.isNotEmpty) ...[
                    Text(
                      'Size',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizeSelector(
                      sizes: widget.product.availableSizes,
                      selectedSize: _selectedSize,
                      onSizeSelected: (size) {
                        setState(() {
                          _selectedSize = size;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      cartProvider.addToCart(
                        widget.product,
                        _selectedColor,
                        _selectedSize.toString(),
                      );
                      _showSnackBar(context, 'Added to cart');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews (${widget.product.reviews.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showReviewForm = !_showReviewForm;
                          });
                        },
                        child:
                            Text(_showReviewForm ? 'Cancel' : 'Write a Review'),
                      ),
                    ],
                  ),
                  if (_showReviewForm) ...[
                    const SizedBox(height: 16),
                    _buildReviewForm(productProvider),
                  ],
                  const SizedBox(height: 16),
                  ReviewList(reviews: widget.product.reviews),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm(ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Rating',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _userRating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _userRating = index + 1.0;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reviewTextController,
          decoration: const InputDecoration(
            labelText: 'Your Review',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_reviewTextController.text.isNotEmpty) {
              // Create a new review
              final review = review_model.Review(
                userName: 'You',
                rating: _userRating,
                comment: _reviewTextController.text,
                date: DateTime.now(),
              );

              // Add the review to the product
              productProvider.addReview(widget.product.id, review);

              // Reset form
              _reviewTextController.clear();
              setState(() {
                _showReviewForm = false;
              });

              _showSnackBar(context, 'Review added successfully');
            } else {
              _showSnackBar(context, 'Please enter a review');
            }
          },
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
