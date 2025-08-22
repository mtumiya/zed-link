import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/animations.dart';
import '../../utils/accessibility.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final phoneNumber = '+260${_phoneController.text}'; // Zambia country code
      
      final success = await authProvider.sendOTP(phoneNumber);
      
      if (success && mounted) {
        AccessibilityHelper.announceForAccessibility(
          context, 
          'Verification code sent successfully. Please check your SMS.'
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: phoneNumber,
            ),
          ),
        );
      } else if (mounted) {
        AccessibilityHelper.announceForAccessibility(
          context, 
          'Failed to send verification code. Please try again.'
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send OTP. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _sendOTP,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 600,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: ResponsiveHelper.getResponsiveAlignment(context),
                children: [
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 60)),
                
                // App Logo/Title
                ScaleInAnimation(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          offset: const Offset(0, 8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      size: ResponsiveHelper.getResponsiveSpacing(context, 64),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 32)),
                
                SlideInAnimation(
                  delay: const Duration(milliseconds: 300),
                  begin: const Offset(0, 0.5),
                  child: ResponsiveText(
                    'Welcome to',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                SlideInAnimation(
                  delay: const Duration(milliseconds: 400),
                  begin: const Offset(0, 0.5),
                  child: ResponsiveText(
                    'Zed Link',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                SlideInAnimation(
                  delay: const Duration(milliseconds: 500),
                  begin: const Offset(0, 0.5),
                  child: ResponsiveText(
                    'Your trusted marketplace and delivery platform',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 48)),
                
                // Phone number input
                SlideInAnimation(
                  delay: const Duration(milliseconds: 600),
                  begin: const Offset(0, 0.3),
                  child: Semantics(
                    label: 'Phone number input field. Enter your Zambian phone number without the country code.',
                    textField: true,
                    hint: 'Example: 971234567',
                    child: ModernTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      hintText: '971234567',
                      prefixText: '+260 ',
                      prefixIcon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 9) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 32)),
                
                // Send OTP button
                SlideInAnimation(
                  delay: const Duration(milliseconds: 700),
                  begin: const Offset(0, 0.3),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Semantics(
                        label: authProvider.isLoading 
                            ? 'Sending verification code, please wait'
                            : 'Send verification code button. Tap to receive SMS verification code.',
                        button: true,
                        enabled: !authProvider.isLoading,
                        child: AnimatedButton(
                          onPressed: authProvider.isLoading ? null : () {
                            AccessibilityHelper.provideFeedback();
                            _sendOTP();
                          },
                          child: ModernButton(
                            text: 'Send Verification Code',
                            icon: Icons.message_rounded,
                            isLoading: authProvider.isLoading,
                            onPressed: authProvider.isLoading ? null : _sendOTP,
                            type: ButtonType.primary,
                            size: const Size(double.infinity, 56),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 32)),
                
                // Info text
                SlideInAnimation(
                  delay: const Duration(milliseconds: 800),
                  begin: const Offset(0, 0.2),
                  child: InfoCard(
                    message: 'We will send you a verification code via SMS to confirm your identity',
                    icon: Icons.info_outline_rounded,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}