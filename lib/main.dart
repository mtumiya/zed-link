import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/admin_provider.dart';
import 'models/delivery.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZedLinkApp());
}

class ZedLinkApp extends StatelessWidget {
  const ZedLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<NotificationProvider, PaymentProvider>(
          create: (context) => PaymentProvider(),
          update: (context, notificationProvider, paymentProvider) {
            paymentProvider!.setOnPaymentCompletedCallback((payment) {
              notificationProvider.notifyPaymentConfirmation(
                userId: payment.orderId, // We'll need to get the actual user ID
                payment: payment,
              );
            });
            return paymentProvider;
          },
        ),
        ChangeNotifierProxyProvider<NotificationProvider, DeliveryProvider>(
          create: (context) => DeliveryProvider(),
          update: (context, notificationProvider, deliveryProvider) {
            deliveryProvider!.setOnDeliveryStatusChangedCallback((delivery, status) {
              switch (status) {
                case DeliveryStatus.assigned:
                  notificationProvider.notifyDeliveryAssigned(
                    userId: delivery.clientId,
                    delivery: delivery,
                  );
                  break;
                case DeliveryStatus.pickedUp:
                  notificationProvider.notifyDeliveryPickedUp(
                    userId: delivery.clientId,
                    delivery: delivery,
                  );
                  break;
                case DeliveryStatus.inTransit:
                  notificationProvider.notifyDeliveryInTransit(
                    userId: delivery.clientId,
                    delivery: delivery,
                  );
                  break;
                case DeliveryStatus.nearDelivery:
                  notificationProvider.notifyDeliveryArriving(
                    userId: delivery.clientId,
                    delivery: delivery,
                  );
                  break;
                case DeliveryStatus.delivered:
                  notificationProvider.notifyDeliveryCompleted(
                    userId: delivery.clientId,
                    delivery: delivery,
                  );
                  break;
                default:
                  break;
              }
            });
            return deliveryProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Zed Link',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
