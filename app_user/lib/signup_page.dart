// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, prefer_const_declarations

import 'package:app_user/home_page.dart';
import 'package:app_user/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int userId = 0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
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

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      String fullName = _fullNameController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();
      String email = _emailController.text.trim();
      String username = _usernameController.text.trim();
      String password = _passwordController.text;

      // print('username is going to send to OTP: $username');
      // goToPage(SendOTPPage(
      //   fullName: fullName,
      //   phoneNumb: phoneNumber,
      //   email: email,
      //   username: username,
      //   password: password,
      // ));

      final String baseUrl = 'http://leap.crossnet.co.id:1762';
      final Uri urlSignUp = Uri.parse('$baseUrl/user');

      final responseSignUp = await http.post(
        urlSignUp,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'nama_lengkap': fullName,
          'email': email,
          'no_telp': phoneNumber,
        }),
      );
      print("status code: ${responseSignUp.statusCode}");

      if (responseSignUp.statusCode == 200) {
        final data = jsonDecode(responseSignUp.body);

        // LOGIN
        var url = Uri.parse('$baseUrl/user/auth');
        print('userame to login ${data['username']}');
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
          print('User Data: $userData');
          setState(() {
            userId = userData['id'];
          });
          print('User ID: ${userData['id']}');
          goToPage(SendOTPPage(userId: userId));
        } else {
          var responseBody = jsonDecode(response.body);
          print('Login failed: ${response.statusCode}');
          print(responseBody['message']);
        }
      } else {
        // Handle sign-up error
        print('Sign-up failed: ${responseSignUp.body}');
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
                  const SizedBox(height: 16),
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
                          controller: _fullNameController,
                          cursorColor: const Color.fromARGB(500, 24, 41, 78),
                          style: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Full Name',
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
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneNumberController,
                          cursorColor: const Color.fromARGB(500, 24, 41, 78),
                          style: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Phone Number',
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
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          cursorColor: const Color.fromARGB(500, 24, 41, 78),
                          style: const TextStyle(
                              color: Color.fromARGB(500, 24, 41, 78)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Email',
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
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
                              onPressed: _signUp,
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Already have an account?'),
                  GestureDetector(
                    onTap: () {
                      goToPage(LoginPage());
                    },
                    child: const Text(
                      'Log In',
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

class SendOTPPage extends StatefulWidget {
  final userId;
  final fullName;
  final phoneNumb;
  final email;
  final username;
  final password;

  const SendOTPPage(
      {super.key,
      this.fullName,
      this.phoneNumb,
      this.email,
      this.username,
      this.password,
      this.userId});

  @override
  State<SendOTPPage> createState() => _SendOTPPageState();
}

class _SendOTPPageState extends State<SendOTPPage> {
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  @override
  void dispose() {
    _otpController1.dispose();
    _otpController2.dispose();
    _otpController3.dispose();
    _otpController4.dispose();
    super.dispose();
  }

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  void _verifyOtp() {
    String otpString = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;

    // Print the OTP code as an integer
    int otpCode = int.parse(otpString);
    print('userID: ${widget.userId}');
    print('OTP Code: $otpCode');

    verifyOtp(widget.userId, otpCode).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verified successfully.')),
        );
        // Navigate to home or next page
        // Navigator.pushReplacementNamed(context, '/home');
        goToPage(LoginPage());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verification failed. Please try again.')),
        );
      }
    });
  }

  Future<bool> verifyOtp(int userId, int otpCode) async {
    final String baseUrl = 'http://leap.crossnet.co.id:1762';
    final Uri url = Uri.parse('$baseUrl/verify/otp');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userid': userId,
        'kode_otp': otpCode,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // Handle success
      if (data['status'] == 200) {
        print('OTP verified: ${data['message']}');
        return true;
      } else {
        // Handle failure
        print('OTP verification failed: ${data['message']}');
        return false;
      }
    } else {
      // Handle HTTP error
      print('HTTP error: ${response.statusCode}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input OTP Code',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('Please input the code that we sent to your email'),
            SizedBox(height: 16),
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOtpTextField(_otpController1),
                  _buildOtpTextField(_otpController2),
                  _buildOtpTextField(_otpController3),
                  _buildOtpTextField(_otpController4),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Resend code',
                style: TextStyle(color: Color.fromARGB(500, 24, 41, 78))),
            Container(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(500, 24, 41, 78),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: _verifyOtp,
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpTextField(TextEditingController controller) {
    return SizedBox(
      height: 80,
      width: 70,
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        cursorColor: Color.fromARGB(500, 24, 41, 78),
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 24),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(400, 24, 41, 78), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(500, 24, 41, 78), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
