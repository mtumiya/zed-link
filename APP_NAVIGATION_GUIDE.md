# 📱 Zed Link - App Navigation Guide

## 🎯 App Overview
Zed Link is a digital marketplace and delivery coordination platform designed for Zambia, connecting clients with suppliers and couriers for efficient order management and delivery.

---

## 🏗️ App Architecture & Navigation Flow

### 📋 **Main User Roles**
1. **Client (Buyer)** - Orders goods and tracks deliveries
2. **Supplier/Producer** - Lists products and manages orders  
3. **Courier** - Delivers goods and updates status
4. **Admin** - Oversees platform operations

---

## 🚀 **Getting Started - Login Flow**

### 1️⃣ **Login Screen** (`lib/screens/auth/login_screen.dart`)
**What you'll see:**
- 🎨 **Beautiful animated logo** with Zed Link branding
- 📱 **Phone number input** with Zambian country code (+260)
- 🔘 **"Send Verification Code" button** with gradient styling
- ℹ️ **Information card** explaining the SMS verification process

**How to use:**
1. Enter your phone number (without country code)
2. Tap "Send Verification Code"
3. You'll receive an SMS with verification code

### 2️⃣ **OTP Verification Screen** (`lib/screens/auth/otp_verification_screen.dart`)
**What you'll see:**
- 🔢 **6-digit verification code input**
- ⏱️ **Countdown timer** for code expiry
- 🔄 **Resend code option** when timer expires

**How to use:**
1. Enter the 6-digit code from SMS
2. Code auto-validates when complete
3. Tap "Resend" if you don't receive the code

### 3️⃣ **Role Selection Screen** (`lib/screens/auth/role_selection_screen.dart`)
**What you'll see:**
- 👤 **User role options** (Client, Supplier, Courier, Admin)
- 📝 **Description** of each role's capabilities
- ✅ **Continue button** to proceed

**How to use:**
1. Select your primary role
2. Tap "Continue" to access your dashboard

---

## 🏠 **Main Navigation - Home Screen** (`lib/screens/home_screen.dart`)

The home screen acts as a **smart router** that directs users to their role-specific dashboard:

```
┌─────────────────┐
│   Home Screen   │ ──┐
│   (Router)      │   │
└─────────────────┘   │
                      │
        ┌─────────────┴─────────────┬─────────────┬─────────────┐
        │                           │             │             │
   ┌────▼────┐              ┌──────▼──┐    ┌─────▼──┐    ┌─────▼──┐
   │ Client  │              │Supplier │    │Courier │    │ Admin  │
   │Dashboard│              │Dashboard│    │Dashboard│    │Dashboard│
   └─────────┘              └─────────┘    └────────┘    └────────┘
```

---

## 🛒 **Client Journey** (Buyers/Retailers/Consumers)

### **Main Dashboard** (`lib/screens/client/client_dashboard.dart`)
**Navigation Structure:**
```
📱 Bottom Navigation:
├── 🏠 Home - Product discovery and featured items
├── 📦 Orders - Order history and tracking
├── 🛒 Cart - Shopping cart management  
├── 👤 Profile - Account settings and preferences
```

### **Key Screens:**

#### 🛍️ **Product Catalog** (`lib/screens/client/product_catalog_screen.dart`)
- Browse products by category
- Filter by location, price, supplier
- Search functionality
- Product cards with images and pricing

#### 📱 **Product Detail** (`lib/screens/client/product_detail_screen.dart`)
- Detailed product information
- Supplier details and ratings
- Quantity selector
- "Add to Cart" functionality
- Delivery options display

#### 🛒 **Shopping Cart** (`lib/screens/client/cart_screen.dart`)
- Review selected items
- Modify quantities
- Remove items
- View total cost
- Proceed to checkout

#### 💳 **Checkout Flow**
1. **Checkout Screen** (`lib/screens/client/checkout_screen.dart`)
   - Delivery address confirmation
   - Payment method selection
   - Order summary review
   
2. **Payment Method** (`lib/screens/client/payment_method_screen.dart`)
   - Mobile money options
   - Card payment
   - Bank transfer
   
3. **Payment Processing** (`lib/screens/client/payment_processing_screen.dart`)
   - Real-time payment status
   - Success/failure feedback

#### 📍 **Order Tracking** (`lib/screens/client/delivery_tracking_screen.dart`)
- Real-time GPS tracking
- Delivery status updates
- Estimated arrival time
- Courier contact information

---

## 🏭 **Supplier Journey** (Producers/Wholesalers)

### **Main Dashboard** (`lib/screens/supplier/supplier_dashboard.dart`)
**Key Features:**
- 📊 Sales analytics and performance metrics
- 📦 New order notifications
- 📈 Inventory management
- 🚛 Delivery assignment options

**Main Functions:**
1. **Product Management**
   - Add/edit product listings
   - Update pricing and availability
   - Manage product categories

2. **Order Management**
   - View incoming orders
   - Accept/reject orders with reasons
   - Assign delivery method (own fleet vs. courier)

3. **Inventory Control**
   - Real-time stock level updates
   - Low stock alerts
   - Bulk inventory updates

4. **Delivery Options**
   - **Own Transport**: Assign to internal drivers
   - **App Courier**: Release to courier network

---

## 🚚 **Courier Journey** (Drivers/Delivery Partners)

### **Main Dashboard** (`lib/screens/courier/courier_dashboard.dart`)
**Key Features:**
- 🗺️ Available delivery requests map view
- 💰 Earnings tracker and payment history
- ⭐ Rating and performance metrics
- 📱 GPS navigation integration

### **Delivery Management** (`lib/screens/courier/courier_deliveries_screen.dart`)
**Workflow:**
1. **Accept Delivery**
   - View pickup and delivery locations
   - Estimated distance and earnings
   - Accept or decline request

2. **Pickup Process**
   - Navigate to supplier location
   - Verify package details and QR codes
   - Update status to "Picked Up"

3. **Delivery Process**
   - GPS navigation to customer
   - Update status to "In Transit"
   - Capture proof of delivery (signature/photo)
   - Complete delivery and receive payment

---

## ⚙️ **Admin Journey** (Platform Management)

### **Admin Dashboard** (`lib/screens/admin/admin_dashboard.dart`)
**Overview Features:**
- 📊 Platform-wide analytics
- 🗺️ Live delivery tracking map
- 📈 Revenue and transaction metrics
- 🚨 Issues and complaints queue

### **Management Screens:**

#### 👥 **User Management** (`lib/screens/admin/admin_users_screen.dart`)
- Approve new supplier/courier registrations
- User verification and document review
- Account status management
- Performance monitoring

#### 📦 **Order Management** (`lib/screens/admin/admin_orders_screen.dart`)
- Platform-wide order monitoring
- Dispute resolution
- Refund processing
- Order analytics

#### 📱 **Analytics** (`lib/screens/admin/admin_analytics_screen.dart`)
- Sales trends and insights
- Geographic performance data
- User behavior analytics
- Platform performance metrics

#### 💬 **Feedback Management** (`lib/screens/admin/admin_feedback_screen.dart`)
- Customer complaints and reviews
- Quality control measures
- Supplier/courier performance issues
- Resolution tracking

---

## 🔔 **Shared Features Across All Roles**

### **Notifications** (`lib/screens/shared/notifications_screen.dart`)
**Types:**
- 📦 Order status updates
- 💰 Payment confirmations
- 🚚 Delivery notifications
- ⭐ Rating requests
- 🚨 System alerts

### **Rating System** (`lib/screens/shared/rate_order_screen.dart`)
**Features:**
- ⭐ 5-star rating system
- 💬 Written feedback
- 📸 Photo attachments
- 🔄 Mutual rating (clients ↔ suppliers/couriers)

### **Feedback** (`lib/screens/shared/feedback_screen.dart`)
- 📝 General platform feedback
- 🐛 Bug reports
- 💡 Feature suggestions
- 📞 Contact support

---

## 🎨 **UI/UX Design Features**

### **Modern Design Elements:**
- ✨ **Smooth animations** - Slide-in effects, scale transitions, micro-interactions
- 🎨 **Material Design 3** - Modern color schemes, elevated surfaces, dynamic theming
- 📱 **Responsive layout** - Adapts to mobile, tablet, and desktop screens
- ♿ **Accessibility** - Screen reader support, high contrast, proper touch targets
- 🔄 **Loading states** - Shimmer effects, skeleton screens, progress indicators

### **Navigation Patterns:**
- 📊 **Bottom Navigation** - Primary navigation for main sections
- 🔝 **App Bar** - Screen titles, back navigation, actions
- 📋 **Tabs** - Secondary navigation within screens
- 🗂️ **Drawers** - Additional navigation options (desktop)
- 🔘 **FAB** - Quick actions (add to cart, new order, etc.)

---

## 🚀 **Quick Start Guide**

### **For New Users:**
1. 📱 **Download** the APK (location provided separately)
2. 📋 **Register** with your phone number
3. ✅ **Verify** using SMS code
4. 👤 **Select** your role (Client/Supplier/Courier)
5. 🎯 **Complete** your profile setup
6. 🚀 **Start** using the platform!

### **For Clients:**
1. 🔍 Browse products in catalog
2. 🛒 Add items to cart
3. 💳 Proceed to checkout
4. 📱 Track your delivery
5. ⭐ Rate your experience

### **For Suppliers:**
1. 📦 List your products
2. 📬 Receive order notifications
3. ✅ Accept and process orders
4. 🚛 Choose delivery method
5. 📊 Monitor your sales

### **For Couriers:**
1. 🗺️ View available deliveries
2. ✅ Accept delivery requests
3. 📱 Navigate using GPS
4. 📸 Capture delivery proof
5. 💰 Track your earnings

---

## 🔧 **Technical Information**

### **File Structure:**
```
lib/
├── main.dart                 # App entry point
├── theme/                    # Material Design theming
├── screens/                  # All app screens
│   ├── auth/                # Login & authentication
│   ├── client/              # Client-specific screens
│   ├── supplier/            # Supplier-specific screens
│   ├── courier/             # Courier-specific screens
│   ├── admin/               # Admin management screens
│   └── shared/              # Common screens
├── widgets/                  # Reusable UI components
├── utils/                    # Utilities (animations, responsive, etc.)
├── providers/                # State management
└── models/                   # Data models
```

### **Key Dependencies:**
- **provider** - State management
- **http** - API communication
- **shared_preferences** - Local storage
- **Material Design 3** - Modern Android theming

---

## 📞 **Support & Help**

- 💬 **In-App Feedback** - Use the feedback screen in any role
- 📧 **Contact Support** - Through admin panel
- 📚 **User Guides** - Available in profile settings
- 🔄 **Updates** - Automatic update notifications

---

*This navigation guide covers the complete user journey for all roles in the Zed Link platform. Each screen has been designed with modern Material Design principles for optimal user experience.*