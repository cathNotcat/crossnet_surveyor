// ignore_for_file: prefer_const_constructors

import 'package:surveyor/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: false,
    ignoreSsl: true,
  );
  runApp(const MainApp());
}

// void main() {
//   runApp(const MainApp());
// }

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
      // home: LocationPermissionPage(),
    );
  }
}
