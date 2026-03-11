import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:password_saver/view/key_input_screen.dart';
import 'package:password_saver/view/login_screen.dart';
import 'package:password_saver/view/password_listing.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir);
  await Hive.openBox("app_storage");
  runApp(const MyApp());
}

Future<dynamic> getApplicationDocumentsDirectory() async {
  final dir = Directory.systemTemp.path;
  return dir;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(

        scaffoldBackgroundColor: const Color(0xFF121212),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),

        cardColor: const Color(0xFF1E1E1E),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),

        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),

      ),

      home: DarkBiometricLoginScreen(),

    );

  }
}
