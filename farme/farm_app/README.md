# Farm App - Agricultural E-commerce Flutter Application

A cross-platform Flutter mobile application that allows users to browse, search, and purchase agricultural or farm products. Built with Firebase backend services and Provider state management.

## Features

### User Features
- **Authentication**: Sign up, login, and logout using Firebase Authentication
- **Product Browsing**: View products in a grid layout with images, prices, and descriptions
- **Search & Filter**: Search products by name/description and filter by categories
- **Shopping Cart**: Add/remove items, update quantities, and view cart total
- **Checkout**: Complete orders with delivery address and payment method selection
- **Order History**: View past orders with status tracking
- **Responsive Design**: Works on various screen sizes

### Admin Features
- **Product Management**: Add, edit, and delete products
- **Order Management**: View all orders and update order status
- **User Management**: View user information and manage roles

### Technical Features
- **Firebase Integration**: Authentication, Firestore database, and Storage
- **State Management**: Provider pattern for app-wide state
- **Real-time Updates**: Live data synchronization with Firestore
- **Image Handling**: Product images with Firebase Storage support
- **Form Validation**: Input validation for all forms

## Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd farm_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Create Firestore database
5. Enable Storage

#### Configure Firebase
1. Add Android app to Firebase project
2. Download `google-services.json` and place it in `android/app/`
3. For iOS, add iOS app and download `GoogleService-Info.plist`

#### Firestore Rules
Set up Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users can read/write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

### 4. Run the Application
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── authContext.dart          # Authentication provider
├── providers/                # State management providers
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   └── order_provider.dart
├── screens/                  # UI screens
│   ├── product_listing.dart
│   ├── product_detail.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── order_confirmation.dart
│   ├── order_history.dart
│   ├── home_screen.dart
│   ├── admin_product_management.dart
│   └── admin_order_management.dart
├── model/                    # Data models
│   ├── product.dart
│   ├── cart_item.dart
│   ├── order.dart
│   └── user.dart
├── auth/                     # Authentication screens
│   ├── signin.dart
│   ├── signup.dart
│   ├── forgot_password.dart
│   └── reset_password.dart
├── home/                     # Home screens
│   ├── welcomepage.dart
│   └── frontpage.dart
├── user_taskbar.dart         # User navigation
└── admin_taskbar.dart        # Admin navigation
```

## Dependencies

- `firebase_core`: Firebase core functionality
- `firebase_auth`: User authentication
- `cloud_firestore`: NoSQL database
- `firebase_storage`: File storage
- `provider`: State management
- `image_picker`: Image selection

## Usage

### For Users
1. **Sign Up/Login**: Create an account or login with existing credentials
2. **Browse Products**: View products by category or search by name
3. **Add to Cart**: Add products to shopping cart
4. **Checkout**: Complete purchase with delivery details
5. **Track Orders**: View order history and status

### For Admins
1. **Login**: Use admin credentials
2. **Manage Products**: Add, edit, or delete products
3. **Manage Orders**: View and update order status
4. **User Management**: View user information

## Database Schema

### Users Collection
```javascript
{
  email: string,
  role: "user" | "admin",
  createdAt: timestamp
}
```

### Products Collection
```javascript
{
  name: string,
  price: number,
  description: string,
  category: string,
  imageUrl: string,
  rating: number
}
```

### Orders Collection
```javascript
{
  userId: string,
  items: [
    {
      product: Product,
      quantity: number
    }
  ],
  total: number,
  status: string,
  address: string,
  paymentMethod: string,
  createdAt: timestamp
}
```

## Deployment

### Android
1. Build APK: `flutter build apk`
2. Build App Bundle: `flutter build appbundle`
3. Upload to Google Play Store

### iOS
1. Build iOS: `flutter build ios`
2. Archive in Xcode
3. Upload to App Store Connect

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support, please open an issue in the repository or contact the development team.

## Future Enhancements

- Push notifications for order updates
- Payment gateway integration
- Real-time chat support
- Product reviews and ratings
- Advanced analytics dashboard
- Multi-language support
- Offline mode support
