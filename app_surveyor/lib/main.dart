import 'package:app_surveyor/detail_surveys.dart';
import 'package:app_surveyor/home_page.dart';
import 'package:app_surveyor/login_page.dart';
import 'package:app_surveyor/search_survey.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // home: HomePage(),
    );
  }
}
