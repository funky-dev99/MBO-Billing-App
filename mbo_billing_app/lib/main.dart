import 'package:flutter/material.dart';

import 'Pages/homePage.dart';
import 'colors.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.darkGreen),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
