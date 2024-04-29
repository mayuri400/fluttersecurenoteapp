import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notes_app/routing/app_pages.dart';
import 'package:notes_app/routing/app_routes.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyC4U0d8OQnm0-qqz7Hk5n2YGktrpP21yRw',
        appId: '1:130370578184:android:2f5283e77e7afe3a28aebd ',
        messagingSenderId: 'sendid',
        projectId: 'noteapp-dedc8',
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Note App by flutter",
        initialRoute: AppRoute.HOME,
        getPages: getRoutes);
  }
}