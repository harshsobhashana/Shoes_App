import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoes_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  UserProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      try {
        final userMap = jsonDecode(userData);
        _user = UserModel.fromJson(userMap);
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserToPrefs() async {
    if (_user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode(_user!.toJson());
    await prefs.setString('user_data', userData);
  }

  // For demo purposes, we'll create a mock login/signup
  Future<bool> login(String email, String password) async {
    // In a real app, this would make an API call
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Mock user for demo
    if (email == 'user@example.com' && password == 'password') {
      _user = UserModel(
        id: '1',
        name: 'Demo User',
        email: email,
        phoneNumber: '1234567890',
        addresses: [
          Address(
            id: '1',
            fullName: 'Demo User',
            addressLine1: '123 Main St',
            city: 'Demo City',
            state: 'Demo State',
            postalCode: '12345',
            country: 'Demo Country',
            isDefault: true,
          )
        ],
      );
      await _saveUserToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    // In a real app, this would make an API call
    await Future.delayed(const Duration(seconds: 1));

    _user = _user!.copyWith(
      name: name ?? _user!.name,
      email: email ?? _user!.email,
      phoneNumber: phoneNumber ?? _user!.phoneNumber,
    );

    await _saveUserToPrefs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    final updatedAddresses = List<Address>.from(_user!.addresses);

    // If this is the first address or marked as default, update others
    if (address.isDefault || updatedAddresses.isEmpty) {
      for (int i = 0; i < updatedAddresses.length; i++) {
        updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
      }
    }

    updatedAddresses.add(address);

    _user = _user!.copyWith(addresses: updatedAddresses);
    await _saveUserToPrefs();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAddress(Address updatedAddress) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    final updatedAddresses = List<Address>.from(_user!.addresses);

    int addressIndex =
        updatedAddresses.indexWhere((addr) => addr.id == updatedAddress.id);
    if (addressIndex != -1) {
      // If the updated address is now default, update others
      if (updatedAddress.isDefault) {
        for (int i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
        }
      }

      updatedAddresses[addressIndex] = updatedAddress;

      _user = _user!.copyWith(addresses: updatedAddresses);
      await _saveUserToPrefs();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    final updatedAddresses =
        _user!.addresses.where((addr) => addr.id != addressId).toList();

    // If we removed the default address and there are other addresses left,
    // make the first one the default
    if (updatedAddresses.isNotEmpty &&
        !updatedAddresses.any((addr) => addr.isDefault)) {
      updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
    }

    _user = _user!.copyWith(addresses: updatedAddresses);
    await _saveUserToPrefs();

    _isLoading = false;
    notifyListeners();
  }
}
