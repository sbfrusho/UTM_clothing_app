import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shopping_app/screens/user/cap-screen.dart';
import 'package:shopping_app/widgets/bottom-navigation.dart';

import 'controller/cart-controller.dart';
import 'screens/splash-scree.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: "AIzaSyA7AjYocASnUxdv4nVcJ3LAWjVva4hjtGY",
    appId: "1:1049642488385:android:eab6445f1f78f7827b6cc0",
    messagingSenderId: "1049642488385",
    projectId: "utm-shopping-app-5b973",
  )
  );

  Get.put(CartController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      
      builder: (BuildContext context, Widget? child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UTM E-COMMERCE APP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

