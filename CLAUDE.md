# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

### Standard Workflow**

1\. First think through the problem, read the codebase for relevant files, and write a plan to tasks/todo.md.

2\. The plan should have a list of todo items that you can check off as you complete them

3\. Before you begin working, check in with me and I will verify the plan.

4\. Then, begin working on the todo items, marking them as complete as you go.

5\. Please every step of the way just give me a high level explanation of what changes you made

6\. Make every task and code change you do as simple as possible. We want to avoid making any massive or complex changes. Every change should impact as little code as possible. Everything is about simplicity.

## Project Overview

This is a Flutter cross-platform mobile application named "zed_link". The project follows standard Flutter project structure with support for Android, iOS, Linux, macOS, Windows, and Web platforms.

## Development Commands

### Essential Commands
- `flutter run` - Run the app in development mode with hot reload
- `flutter run -d chrome` - Run the app in Chrome browser
- `flutter run -d windows` - Run the app on Windows desktop
- `flutter test` - Run all widget and unit tests
- `flutter analyze` - Run static analysis and linting
- `flutter pub get` - Install dependencies from pubspec.yaml
- `flutter pub upgrade` - Upgrade dependencies to latest versions
- `flutter clean` - Clean build artifacts
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (macOS only)
- `flutter build web` - Build web version

### Testing
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter test --coverage` - Run tests with coverage report

## Project Structure

### Core Application
- `lib/main.dart` - Main entry point with MyApp and MyHomePage widgets
- `test/widget_test.dart` - Widget tests for the counter functionality

### Platform-Specific Code
- `android/` - Android-specific configuration and native code
- `ios/` - iOS-specific configuration and native code  
- `linux/` - Linux desktop configuration
- `macos/` - macOS desktop configuration
- `windows/` - Windows desktop configuration
- `web/` - Web-specific assets and configuration

### Configuration Files
- `pubspec.yaml` - Dependency management and app metadata
- `analysis_options.yaml` - Static analysis configuration using flutter_lints

## Development Notes

### Dependencies
- Uses Material Design with `cupertino_icons` for iOS-style icons
- Configured with `flutter_lints` for recommended linting rules
- Targets Dart SDK ^3.9.0

### Code Style
- Follows standard Flutter/Dart conventions
- Uses flutter_lints package for consistent code quality
- Includes comprehensive inline documentation in main.dart

### Architecture
- Currently implements a simple counter app with StatefulWidget pattern
- Uses Material Design theming with ColorScheme.fromSeed
- Follows Flutter's recommended widget composition patterns

### Testing Strategy
- Widget tests verify UI behavior and state management
- Uses flutter_test framework with WidgetTester
- Tests cover basic counter functionality and widget interactions

### Android app development 
Lusaka Order & Courier App
Version: 1.0
Purpose:
To create a digital marketplace and delivery coordination platform that streamlines the process of ordering goods from suppliers and ensuring efficient, reliable delivery through a combination of supplier-managed transport and external couriers.
________________________________________
1. System Overview
   The Lusaka Order & Courier App is a mobile and web-based platform designed to connect clients (retailers, wholesalers, and consumers) with producers/suppliers and delivery services. It allows for order placement, payment, tracking, and feedback in a single, integrated system.
   It is tailored to Zambia’s market realities, including:
   •	Multiple payment methods (mobile money, card, bank transfer)
   •	Dual delivery model (supplier’s own transport OR registered courier)
   •	Multi-language support (English, Bemba, Nyanja)
   •	Offline-friendly features for areas with poor internet connectivity
________________________________________
2. Key Actors
1.	Client (Buyer)
      o	Individuals, retailers, or wholesalers purchasing goods.
2.	Supplier/Producer/Wholesaler
      o	Businesses selling goods (e.g., farms, factories, warehouses).
3.	Courier/Transporter
      o	Independent drivers, bike riders, or logistics companies delivering goods.
4.	Supplier Dispatch/Warehouse Staff
      o	Verify orders, package goods, and load vehicles.
5.	Management/Admin Team
      o	Oversee platform operations, approve supplier registrations, resolve disputes, and manage payments.
________________________________________
3. User Roles & Permissions
   3.1 Client
   Capabilities:
   •	Register/login with phone number + OTP (2FA security).
   •	Browse suppliers by category, location, or product type.
   •	View product details, pricing, available quantities, and delivery options.
   •	Add products to cart, place orders, and make payments.
   •	Choose delivery mode (supplier’s transport or app courier).
   •	Track order status and delivery in real time.
   •	Receive notifications via SMS, WhatsApp, and in-app alerts.
   •	Download receipts and delivery notes (PDF).
   •	Rate suppliers and couriers after delivery.
   •	Raise complaints or request refunds via in-app form.
________________________________________
3.2 Supplier
Capabilities:
•	Register with business details, product catalog, pricing, and delivery capabilities.
•	Set default delivery method:
o	Own transport fleet (managed via supplier dashboard).
o	App-assigned courier service.
•	Receive order notifications instantly.
•	Accept or reject orders (with reasons).
•	Assign orders to internal drivers or release them to the courier network.
•	Manage warehouse/dispatch workflow: order verification, packaging, labeling.
•	Update stock levels in real-time.
•	View sales analytics (best-selling products, client trends, delivery performance).
•	Manage returns and refunds.
________________________________________
3.3 Courier/Transporter
Capabilities:
•	Register as a driver, bike rider, or truck operator with verified ID, vehicle, and license.
•	Accept or decline delivery requests.
•	Navigate to pickup and drop-off points via integrated GPS maps.
•	Update delivery status at key points (picked up, in transit, delivered).
•	Capture proof of delivery (signature/photo upload).
•	View delivery earnings and payment history.
•	Rate clients and suppliers for professionalism and efficiency.
________________________________________
3.4 Supplier Dispatch/Warehouse Staff
Capabilities:
•	View new and pending orders.
•	Verify item quantities, sizes, and packaging.
•	Print or generate QR-coded labels for each order.
•	Confirm loading onto the correct vehicle (supplier fleet or courier vehicle).
•	Update order status (ready for pickup, dispatched).
________________________________________
3.5 Management/Admin Team
Capabilities:
•	Approve new supplier and courier registrations after verification.
•	Monitor live orders and deliveries on a dashboard map.
•	Access platform-wide analytics (sales, delivery times, customer satisfaction).
•	Resolve complaints and approve refunds.
•	Manage payment settlements to suppliers and couriers.
•	Control system settings, pricing for courier services, and promotional campaigns.
•	Generate monthly performance reports.
________________________________________
4. Workflow
   Step 1 – Client Order Placement
   •	Client logs in → Browses products → Adds to cart → Chooses delivery mode → Pays via mobile money, card, or bank transfer.
   •	System sends order confirmation to client, supplier, and relevant courier (if external).
   Step 2 – Order Processing
   •	Supplier verifies order → Updates stock → Prepares package.
   •	Labels package with QR code (order ID, client name, delivery address).
   Step 3 – Delivery Assignment
   •	If supplier delivery: Supplier assigns an internal driver and updates estimated delivery time.
   •	If external courier: System assigns best-matched courier (based on proximity, vehicle size, and ratings).
   Step 4 – Delivery
   •	Courier/driver picks up goods → Updates "Picked Up" status.
   •	Client receives real-time tracking.
   •	Courier delivers goods → Captures proof of delivery → Client signs electronically.
   Step 5 – Post-Delivery
   •	Delivery note and receipt sent to client (PDF, WhatsApp).
   •	Client rates experience.
   •	Payment is settled to supplier and courier via platform.
________________________________________
5. Payment System
   •	Clients → Platform: Mobile money, card, or bank transfer.
   •	Platform → Supplier & Courier: Automated settlements after successful delivery.
   •	Transaction history available for all users.
________________________________________
6. Management & Quality Control
   •	Live dashboard for monitoring operations.
   •	Supplier and courier performance scoring system (low scores trigger review).
   •	Periodic random checks on deliveries for compliance.
   •	Fraud detection and prevention measures (e.g., blocking suspicious accounts).
________________________________________
7. Notifications
   •	Order confirmation
   •	Payment confirmation
   •	Package ready for pickup
   •	In-transit updates
   •	Delivery arrival alerts
   •	Feedback request
   (All via SMS, in-app alerts, and optional WhatsApp.)
________________________________________
8. Reporting & Analytics
   •	Clients: Order history, spending trends.
   •	Suppliers: Sales trends, best-selling products.
   •	Couriers: Delivery count, average time per delivery.
   •	Management: Revenue, delivery success rate, complaint rate, geographic sales spread.
________________________________________
9. Scalability Plan
   •	Phase 1: Lusaka metropolitan area.
   •	Phase 2: Copperbelt & Central Province.
   •	Phase 3: Cross-border trade corridors (Chirundu, Kasumbalesa, Nakonde).
________________________________________
10. Benefits
    •	Clients: Convenience, transparency, fast delivery.
    •	Suppliers: Wider market, reduced manual processing, better customer insights.
    •	Couriers: More job opportunities, guaranteed payments.
    •	Management: Centralized oversight, data-driven decision-making.
