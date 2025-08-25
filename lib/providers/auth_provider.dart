import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;

class AuthProvider with ChangeNotifier {
  app_user.User? _currentUser;
  bool _isLoading = false;
  String? _pendingPhoneNumber;
  String? _sentOTP;
  
  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  
  AuthProvider() {
    _loadStoredUser();
  }
  
  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final phoneNumber = prefs.getString('phone_number');
    final userName = prefs.getString('user_name');
    final userRoleString = prefs.getString('user_role');
    
    if (userId != null && phoneNumber != null) {
      app_user.UserRole role = app_user.UserRole.client;
      if (userRoleString != null) {
        role = app_user.UserRole.values.firstWhere(
          (e) => e.toString() == userRoleString,
          orElse: () => app_user.UserRole.client,
        );
      }
      
      _currentUser = app_user.User(
        id: userId,
        phoneNumber: phoneNumber,
        name: userName ?? 'User',
        role: role,
        isVerified: true,
        createdAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
  
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate OTP sending delay
    await Future.delayed(const Duration(seconds: 2));
    
    _pendingPhoneNumber = phoneNumber;
    _sentOTP = '123456'; // Mock OTP for demo
    
    _isLoading = false;
    notifyListeners();
    
    print('Mock OTP sent to $phoneNumber: $_sentOTP');
    return true;
  }
  
  Future<bool> verifyOTP(String otp) async {
    if (_pendingPhoneNumber == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock verification - accept 123456 or any 6-digit code for demo
    final isValidOTP = otp == _sentOTP || otp.length == 6;
    
    if (isValidOTP) {
      // Check if this is an admin phone number
      if (_isAdminPhoneNumber(_pendingPhoneNumber!)) {
        // Create admin user directly without registration
        await _createAdminUser(_pendingPhoneNumber!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // For regular users, don't create user yet - wait for role selection
      _isLoading = false;
      notifyListeners();
      return true;
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }
  
  Future<void> completeUserRegistration({
    required String name,
    required app_user.UserRole role,
  }) async {
    if (_pendingPhoneNumber == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Simulate registration delay
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = app_user.User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: _pendingPhoneNumber!,
      name: name,
      role: role,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    
    // Store user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _currentUser!.id);
    await prefs.setString('phone_number', _currentUser!.phoneNumber);
    await prefs.setString('user_name', _currentUser!.name);
    await prefs.setString('user_role', role.toString());
    
    _pendingPhoneNumber = null;
    _sentOTP = null;
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _currentUser = null;
    _pendingPhoneNumber = null;
    _sentOTP = null;
    notifyListeners();
  }
  
  // Check if phone number belongs to an admin
  bool _isAdminPhoneNumber(String phoneNumber) {
    // List of admin phone numbers (you can modify this list)
    final adminNumbers = [
      '+260971234567', // Example admin number
      '+260987654321', // Another example admin number
    ];
    
    return adminNumbers.contains(phoneNumber);
  }
  
  // Create admin user directly
  Future<void> _createAdminUser(String phoneNumber) async {
    _currentUser = app_user.User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: phoneNumber,
      name: 'Administrator',
      role: app_user.UserRole.admin,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    
    // Store admin user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _currentUser!.id);
    await prefs.setString('phone_number', _currentUser!.phoneNumber);
    await prefs.setString('user_name', _currentUser!.name);
    await prefs.setString('user_role', _currentUser!.role.toString());
    
    _pendingPhoneNumber = null;
    _sentOTP = null;
  }
}