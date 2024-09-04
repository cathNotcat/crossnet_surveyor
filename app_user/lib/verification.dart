// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class HasBeenSent extends StatefulWidget {
  final String title;
  final String detail;
  const HasBeenSent({super.key, required this.title, required this.detail});

  @override
  State<HasBeenSent> createState() => _HasBeenSentState();
}

class _HasBeenSentState extends State<HasBeenSent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 160,
              color: Color.fromARGB(500, 24, 41, 78),
            ),
            SizedBox(height: 32),
            Text(
              widget.title,
              style: TextStyle(
                  color: Color.fromARGB(500, 24, 41, 78),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              widget.detail,
              style: TextStyle(
                color: Color.fromARGB(500, 24, 41, 78),
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              color: Color.fromARGB(255, 242, 243, 247),
              width: double.infinity,
              height: 80,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color.fromARGB(500, 24, 41, 78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'BACK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(500, 24, 41, 78),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
