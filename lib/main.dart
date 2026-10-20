import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Yeh import lazmi add karein
import 'firebase_options.dart'; // 2. Yeh file bhi import karein

import 'app.dart';
import 'providers/shop_provider.dart';

void main() async { // 3. 'async' yahan lagana hai
  // 4. Yeh dono lines add karni hain
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ShopProvider(),
      child: const WatchHubApp(),
    ),
  );
}