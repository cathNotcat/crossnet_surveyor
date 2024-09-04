// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:app_user/verification.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CompanyRequest extends StatefulWidget {
  const CompanyRequest({super.key});

  @override
  State<CompanyRequest> createState() => _CompanyRequestState();
}

class _CompanyRequestState extends State<CompanyRequest> {
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnImage == null) return;
    setState(() {
      _selectedImage = File(returnImage!.path);
    });
  }

  File? _selectedImage;

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
      appBar: AppBar(
        title: Text(
          'Request Company',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 242, 243, 247),
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text('Company Name', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                    ),
                    SizedBox(height: 8),
                    Text('Username', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                    ),
                    SizedBox(height: 8),
                    Text('Location', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                    ),
                    SizedBox(height: 8),
                    Text('Type', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                    ),
                    SizedBox(height: 8),
                    Text('Ownership Document', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: Container(
                        height: 60,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              // foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _pickImageFromGallery();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Upload File',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(500, 24, 41, 78),
                                  ),
                                ),
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: Color.fromARGB(500, 24, 41, 78),
                                ),
                              ],
                            )),
                      ),
                    ),
                    SizedBox(height: 8),
                    _selectedImage != null
                        ? Image.file(_selectedImage!)
                        : Text('select an image'),
                    SizedBox(height: 8),
                    Text('Company Document', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: Container(
                        height: 60,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              // foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _pickImageFromGallery();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Upload File',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(500, 24, 41, 78),
                                  ),
                                ),
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: Color.fromARGB(500, 24, 41, 78),
                                ),
                              ],
                            )),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Initial Capital', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                    ),
                    SizedBox(height: 8),
                    Text('Description', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      minLines: 3,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.white,
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
                      keyboardType: TextInputType.multiline,
                      textAlignVertical:
                          TextAlignVertical.top, // Aligns text to the top
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      color: Color.fromARGB(255, 242, 243, 247),
                      height: 80,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          // backgroundColor: const Color.fromARGB(500, 24, 41, 78),
                          // foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(500, 24, 41, 78),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      color: Color.fromARGB(255, 242, 243, 247),
                      height: 80,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(500, 24, 41, 78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        onPressed: () {
                          goToPage(HasBeenSent(
                              title: 'DATA HAS BEEN SENT',
                              detail:
                                  'Your sign-up request has been sent. Please wait for the verification.'));
                        },
                        child: const Text(
                          'ADD',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
