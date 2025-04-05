import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shoes_app/providers/cart_provider.dart';
import 'package:shoes_app/providers/order_provider.dart';
import 'package:shoes_app/providers/product_provider.dart';
import 'package:shoes_app/providers/theme_provider.dart';
import 'package:shoes_app/providers/user_provider.dart';
import 'package:shoes_app/providers/wishlist_provider.dart';
import 'package:shoes_app/screens/cart_screen.dart';
import 'package:shoes_app/screens/checkout_screen.dart';
import 'package:shoes_app/screens/home_screen.dart';
import 'package:shoes_app/screens/my_orders_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Add some debug output for asset loading
  debugPrint('Starting Shoes App');
  debugPrint('Checking assets availability...');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating ProductProvider...');
          return ProductProvider();
        }),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Shoes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      routes: {
        '/': (context) => const HomeScreen(),
        '/debug-assets': (context) => const DebugAssetsScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
      initialRoute: '/',
    );
  }
}

class DebugAssetsScreen extends StatefulWidget {
  const DebugAssetsScreen({super.key});

  @override
  State<DebugAssetsScreen> createState() => _DebugAssetsScreenState();
}

class _DebugAssetsScreenState extends State<DebugAssetsScreen> {
  String _assetContent = 'Loading...';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String jsonData =
          await rootBundle.loadString('assets/images/products.json');
      final Map<String, dynamic> data = json.decode(jsonData);
      final int productCount = (data['products'] as List).length;

      setState(() {
        _assetContent = 'Successfully loaded products.json\n'
            'Found $productCount products\n\n'
            'First 200 characters:\n${jsonData.substring(0, 200)}...';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Assets'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Asset Loading Test',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_error != null)
                Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading asset:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAsset,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_assetContent),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
