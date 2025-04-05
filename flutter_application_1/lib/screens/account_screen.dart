import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoes_app/providers/user_provider.dart';
import 'package:shoes_app/screens/address_list_screen.dart';
import 'package:shoes_app/screens/login_screen.dart';
import 'package:shoes_app/screens/my_orders_screen.dart';
import 'package:shoes_app/screens/profile_edit_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final theme = Theme.of(context);

    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    user.phoneNumber,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Personal Information',
              subtitle: 'Edit your profile details',
              icon: Icons.person,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ),
            ),
            _buildMenuCard(
              context: context,
              title: 'My Orders',
              subtitle: 'View your order history and purchased products',
              icon: Icons.shopping_bag,
              onTap: () => Navigator.pushNamed(context, '/my-orders'),
            ),
            _buildMenuCard(
              context: context,
              title: 'My Addresses',
              subtitle: 'Manage your delivery addresses',
              icon: Icons.location_on,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressListScreen()),
              ),
            ),
            _buildMenuCard(
              context: context,
              title: 'Settings',
              subtitle: 'Notifications, password, etc',
              icon: Icons.settings,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    userProvider.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
