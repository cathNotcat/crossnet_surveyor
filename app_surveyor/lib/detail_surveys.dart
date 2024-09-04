// ignore_for_file: prefer_const_constructors

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailSurveys extends StatefulWidget {
  final int assetId;
  final String assetName;
  const DetailSurveys(
      {super.key, required this.assetId, required this.assetName});

  @override
  State<DetailSurveys> createState() => _DetailSurveysState();
}

class _DetailSurveysState extends State<DetailSurveys> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  int id = 0;
  String nama = '';
  String location = '';
  String type = '';
  String usage = '';
  int area = 0;
  int value = 0;
  String condition = '';

  late TextEditingController _usageController;
  late TextEditingController _areaController;
  late TextEditingController _valueController;
  late TextEditingController _conditionController;
  @override
  void initState() {
    super.initState();
    _loadAsset();
    _usageController = TextEditingController();
    _areaController = TextEditingController();
    _valueController = TextEditingController();
    _conditionController = TextEditingController();
  }

  Future<void> _loadAsset() async {
    var url = Uri.parse('$baseUrl/asset/${widget.assetId}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      setState(() {
        id = data['id_asset'];
        nama = data['nama'];
        location = data['alamat'];
        type = data['tipe'];
        usage = data['usage'];
        area = data['luas'];
        value = data['nilai'];
        condition = data['kondisi'];
        _usageController.text = usage;
        _areaController.text = area.toString();
        _valueController.text = value.toString();
        _conditionController.text = condition;
        print(_usageController.text);
        print(_areaController.text);
        print(_valueController.text);
        print(_conditionController.text);
      });
    } else {
      print('Response error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surveys for ${widget.assetName}',
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
              GestureDetector(
                onTap: () {
                  print('add photos');
                },
                child: DottedBorder(
                  color: const Color.fromARGB(255, 24, 41, 78),
                  strokeWidth: 2,
                  dashPattern: [6, 3],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    width: 150,
                    height: 150,
                    child: const Column(
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 48,
                          color: Color.fromARGB(255, 24, 41, 78),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Photos',
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text('Asset ID', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: '$id',
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
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: location,
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
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: type,
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
                    Text('Usage', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _usageController,
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
                    Text('Area', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _areaController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                    Text('Value', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _valueController,
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
                    Text('Condition', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _conditionController,
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
                    Text('Tags', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        // labelText: 'B004',
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
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(500, 24, 41, 78),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistorySurveys extends StatefulWidget {
  final int assetId;
  final String assetName;
  const HistorySurveys(
      {super.key, required this.assetId, required this.assetName});

  @override
  State<HistorySurveys> createState() => _HistorySurveysState();
}

class _HistorySurveysState extends State<HistorySurveys> {
  // final locationController = Location();

  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.3861, -122.0839);

  LatLng? currentPosition;

  final List<String> tags = [
    'Cafe',
    'Restaurant',
  ];

  final List<String> imageUrls = [
    'lib/images/dummy.jpeg',
    'lib/images/dummy.jpeg',
    'lib/images/dummy.jpeg',
    'lib/images/dummy.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History for ${widget.assetName}',
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
              Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(child: Text(tags[index])),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(
                          color: Color.fromARGB(500, 24, 41, 78),
                          width: 1.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                // padding: EdgeInsets.all(16.0),
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      // width: 150,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Image.asset(
                        imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text('Asset ID', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'B004',
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
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Jalan ZYX No. 88',
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
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Building',
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
                    Text('Usage', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Cafe, Restaurant',
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
                    Text('Area', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: '567 m^2',
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
                    Text('Value', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Rp. 3.400.000.000,-',
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
                    Text('Condition', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Color(0xFFBDBDBD),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'lorem ipsum ajs;dfjk jafiowe ghiodjaoijsdf jfaiwoej',
                        // _controller.text.isEmpty ? 'Hint text here' : _controller.text,
                        style: TextStyle(
                          color: Color.fromARGB(255, 24, 41, 78),
                          // color: _controller.text.isEmpty
                          //     ? Color.fromARGB(255, 24, 41, 78).withOpacity(0.5)
                          //     : Color.fromARGB(255, 24, 41, 78), // Regular color
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Coordinate', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      // controller: _usernameController,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: const TextStyle(
                          color: Color.fromARGB(500, 24, 41, 78)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: googlePlex.toString(),
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
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: googlePlex, zoom: 13),
                        markers: {
                          Marker(
                            markerId: MarkerId('sourceLocation'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: googlePlex,
                          ),
                          Marker(
                            markerId: MarkerId('destinationLocation'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: mountainView,
                          ),
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Verification Status', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Color(0xFFBDBDBD),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'DONE',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
