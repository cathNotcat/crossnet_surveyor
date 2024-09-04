// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:app_user/home_page.dart';
import 'package:app_user/signup_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String password = _passwordController.text;

      print('Starting login process');
      try {
        String baseUrl;
        // baseUrl = 'http://10.0.2.2:2681';
        baseUrl = 'http://leap.crossnet.co.id:1762';

        var url = Uri.parse('$baseUrl/user/auth');
        print('Sending request to $url');
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );

        print('Response received: ${response.statusCode}');
        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          print('Login successful: ${responseBody['message']}');
          var userData = responseBody['data'];

          // Handle SharedPreferences asynchronously
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userData['id']);

          goToPage(const HomePage());
        } else {
          var responseBody = jsonDecode(response.body);
          setState(() {
            _errorMessage = 'Username/Password invalid';
          });
          print('Login failed: ${response.statusCode}');
          print(responseBody['message']);
        }
      } catch (error) {
        print('Error during login: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: sized_box_for_whitespace
                  Container(
                    width: 280,
                    child: Image.asset(
                      'lib/images/logo_crossnet.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(500, 242, 243, 247),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.only(
                        top: 24, left: 24, right: 24, bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          cursorColor: const Color.fromARGB(500, 24, 41, 78),
                          style: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Username',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(500, 24, 41, 78),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          cursorColor: const Color.fromARGB(500, 24, 41, 78),
                          style: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(500, 24, 41, 78),
                              ),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        Container(
                          padding: const EdgeInsets.only(top: 40),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(500, 24, 41, 78),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: _login,
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor:
                              const Color.fromARGB(500, 24, 41, 78),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        onPressed: () {
                          goToPage(ForgotPasswordPage());
                        },
                        child: const Text('forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Text('Don\'t have an account?'),
                  GestureDetector(
                    onTap: () {
                      goToPage(SignupPage());
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(500, 24, 41, 78),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: sized_box_for_whitespace
                  Container(
                    width: 280,
                    child: Image.asset(
                      'lib/images/logo_crossnet.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(500, 242, 243, 247),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.only(
                        top: 24, left: 24, right: 24, bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          cursorColor: const Color.fromARGB(500, 24, 41, 78),
                          style: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Your Email',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(500, 24, 41, 78),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 40),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(500, 24, 41, 78),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {
                                goToPage(LoginPage());
                              },
                              child: const Text(
                                'SEND',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
