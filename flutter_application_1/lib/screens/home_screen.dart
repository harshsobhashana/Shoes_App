import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shoes_app/providers/cart_provider.dart';
import 'package:shoes_app/providers/product_provider.dart';
import 'package:shoes_app/providers/theme_provider.dart';
import 'package:shoes_app/screens/account_screen.dart';
import 'package:shoes_app/screens/cart_screen.dart';
import 'package:shoes_app/screens/wishlist_screen.dart';
import 'package:shoes_app/widgets/product_grid.dart';
import 'package:shoes_app/widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeContent(),
    const WishlistScreen(),
    const CartScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartProvider.itemCount > 0,
              label: Text(cartProvider.itemCount.toString()),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoes Shop'),
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search bar
              showSearch(
                context: context,
                delegate: ShoeSearchDelegate(productProvider),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner carousel
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: PageView(
                  children: [
                    _buildBanner(context, 'Summer Sale',
                        'Up to 50% off on selected items', Colors.blue),
                    _buildBanner(context, 'New Arrivals',
                        'Check out the latest styles', Colors.orange),
                    _buildBanner(context, 'Limited Edition',
                        'Exclusive designs for you', Colors.purple),
                  ],
                ),
              ),

              // Categories
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (kDebugMode)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/debug-assets');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                        ),
                        child: const Text('Debug'),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _buildCategoryItem(
                        context, 'Running', Icons.directions_run),
                    _buildCategoryItem(
                        context, 'Basketball', Icons.sports_basketball),
                    _buildCategoryItem(
                        context, 'Football', Icons.sports_soccer),
                    _buildCategoryItem(context, 'Casual', Icons.weekend),
                    _buildCategoryItem(context, 'Fashion', Icons.style),
                  ],
                ),
              ),

              // Top brands
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Brands',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        _showBrandsDialog(context, productProvider);
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: productProvider.brands
                      .take(5)
                      .map((brand) =>
                          _buildBrandItem(context, brand, productProvider))
                      .toList(),
                ),
              ),

              // Trending now
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending Now',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    DropdownButton<String>(
                      value: productProvider.sortBy,
                      items: productProvider.sortOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          productProvider.setSortOption(value);
                        }
                      },
                      underline: Container(),
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),

              // Product grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ProductGrid(),
              ),

              // Show debug button in case of issues
              if (kDebugMode && productProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/debug-assets');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red[900],
                    ),
                    child: const Text('Debug Assets'),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterBottomSheet(context);
        },
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildBanner(
      BuildContext context, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String name, IconData icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandItem(
      BuildContext context, String brand, ProductProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setBrand(brand);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: provider.selectedBrand == brand
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: provider.selectedBrand == brand
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            brand,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: provider.selectedBrand == brand
                  ? Theme.of(context).primaryColor
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showBrandsDialog(BuildContext context, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Brand'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.brands.length,
            itemBuilder: (context, index) {
              final brand = provider.brands[index];
              return RadioListTile<String>(
                title: Text(brand),
                value: brand,
                groupValue: provider.selectedBrand,
                onChanged: (value) {
                  if (value != null) {
                    provider.setBrand(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.setBrand('All');
              Navigator.pop(context);
            },
            child: const Text('CLEAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}

class ShoeSearchDelegate extends SearchDelegate {
  final ProductProvider productProvider;

  ShoeSearchDelegate(this.productProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    productProvider.setSearchQuery(query);
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text('Search for shoes...'),
          ],
        ),
      );
    }

    productProvider.setSearchQuery(query);
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredProducts = productProvider.filteredProducts;

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text('No results found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),
          title: Text(product.name),
          subtitle: Text(product.brand),
          trailing: Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            // Navigate to product details
            close(context, product);
          },
        );
      },
    );
  }
}
