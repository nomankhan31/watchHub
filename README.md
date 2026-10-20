# WatchHub — Flutter + Firebase

A starter e-commerce app for wristwatches with authentication, Firestore product catalog,
search/filter/sorting, product details, local cart, cloud wishlist, checkout/order history,
profile editing, reviews, FAQs and support tickets.

## 1. Requirements
- Flutter stable SDK and Android Studio/VS Code
- A Firebase project
- Android emulator/device or iOS simulator

## 2. Install dependencies
```bash
flutter pub get
```

## 3. Connect Firebase
Install Firebase CLI and FlutterFire CLI, then sign in:
```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```
Choose your Firebase project and platforms. FlutterFire CLI creates `lib/firebase_options.dart`.
Then update `lib/main.dart` to use generated options:
```dart
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```
If you configure only Android, still use the generated options line.

## 4. Enable Firebase services
In Firebase Console:
1. Authentication → Sign-in method → enable **Email/Password**.
2. Firestore Database → create database.
3. Storage → get started.
4. Deploy `firestore.rules` and `storage.rules` from this project using Firebase Console or Firebase CLI.

## 5. Add sample products
Create a `products` collection. Add documents with these fields:
```json
{
  "name": "Classic Chronograph",
  "brand": "WatchHub",
  "category": "Chronograph",
  "description": "A refined stainless-steel watch for everyday wear.",
  "imageUrl": "https://YOUR_IMAGE_URL",
  "imageUrls": ["https://YOUR_IMAGE_URL"],
  "price": 18500,
  "oldPrice": 22000,
  "rating": 4.7,
  "reviewCount": 18,
  "stock": 12,
  "specifications": ["Stainless steel case", "Water resistance: 5 ATM", "Quartz movement"],
  "active": true
}
```
Repeat for multiple products. `imageUrl` must be a publicly readable HTTPS image URL or a Firebase Storage download URL. Upload product photos to Storage `product-images/` (admin upload workflow is not included in this starter; add it to a separate admin app or use the Firebase Console).

## 6. Make an admin account
1. Register normally in the app.
2. In Firestore, open `users/{your-auth-uid}`.
3. Change `role` from `customer` to `admin`.
The security rules then permit that account to create/update/delete products and manage orders/support tickets. This starter does **not** include an in-app admin dashboard or image upload interface; these can be added next.

## 7. Run
```bash
flutter run
```

## Notes before production
- Cart is stored in app memory and resets when the app process restarts.
- Wishlist, orders, reviews, profiles and support tickets use Firestore.
- Delivery fee is currently Rs. 0 and is displayed as such. Set your real delivery fee.
- Checkout writes order documents but does not reserve/decrement stock transactionally. For production, use a trusted Cloud Function/backend transaction to validate prices and stock.
- Bank transfer is a manual payment option, not an online payment gateway.
- Review averages are not automatically recalculated. Add a trusted backend/Cloud Function before using ratings for decisions.
- Never ship permissive Firestore/Storage rules. Test rules with Firebase Emulator Suite before production.
