// ignore_for_file: prefer_const_constructors

import 'package:app_user/company_home_page.dart';
import 'package:app_user/company_request.dart';
import 'package:app_user/detail_asset_comp.dart';
import 'package:app_user/home_page.dart';
import 'package:app_user/login_page.dart';
import 'package:app_user/signup_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Color.fromARGB(255, 242, 243, 247)),
        scaffoldBackgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // home: CompanyHomePage(),
      // home: SendOTPPage(),
    );
  }
}
