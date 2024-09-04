// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, prefer_typing_uninitialized_variables

import 'package:app_user/detail_asset_comp.dart';
import 'package:app_user/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyHomePage extends StatefulWidget {
  final companyId;
  const CompanyHomePage({super.key, this.companyId});

  @override
  State<CompanyHomePage> createState() => _CompanyHomePageState();
}

class _CompanyHomePageState extends State<CompanyHomePage> {
  Map<String, dynamic>? userData;
  List<String> assetNames = [];

  String usernamePerusahaan = '';
  String lokasiPerusahaan = '';
  String kelas = '';
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    _loadPerusahaanData();
    _loadUserData();
    _fetchAssets();
  }

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      String baseUrl;
      baseUrl = 'http://leap.crossnet.co.id:1762';
      var url = Uri.parse('$baseUrl/user/$userId');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        setState(() {
          userData = data;
        });
        print('userdata: $userData');
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> _loadPerusahaanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    await prefs.setInt('perusahaan_id', widget.companyId);
    int? compId = prefs.getInt('perusahaan_id');
    print('userID di profile: $userId');
    print('compID di profile: $compId');

    if (userId != null) {
      String baseUrl;
      baseUrl = 'http://leap.crossnet.co.id:1762';
      var url = Uri.parse('$baseUrl/perusahaan/detail/${widget.companyId}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        if (data is Map<String, dynamic>) {
          setState(() {
            usernamePerusahaan = data['username'] ?? '';
            lokasiPerusahaan = data['lokasi'] ?? '';
          });
        } else {
          print('Failed to load user data: ${response.statusCode}');
        }
      } else {
        print('User ID not found in SharedPreferences');
      }
    }
  }

  Future<void> _fetchAssets() async {
    String baseUrl = 'http://leap.crossnet.co.id:1762';
    var url = Uri.parse('$baseUrl/asset');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Response data: $data');
        var assets = data['data'] as List;
        if (assets.isNotEmpty) {
          for (var asset in assets) {
            assetNames.add(asset['nama']);
          }
        } else {
          print('No assets found');
        }
      } else {
        print('Failed to load assets. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching assets: $error');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    print('User logged out');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  int _selectedIndex = 0;

  List<Widget> _widgetOptions() {
    return <Widget>[
      const AssetsList(),
      const RentedDetails(),
      const RequestList(),
      ProfileList(
        usernamePerusahaan: usernamePerusahaan,
        companyId: widget.companyId,
      ),
      const Text(
        'Settings',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      const Text(
        'Log Out',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? Text(
                'Hello, $usernamePerusahaan',
                style: const TextStyle(color: Colors.white),
              )
            : null,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotificationList(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                ),
              ]
            : null,
        backgroundColor: const Color.fromARGB(255, 24, 41, 78),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: userData != null
          ? _widgetOptions()[_selectedIndex]
          : Center(child: const CircularProgressIndicator()),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Image.asset(
                'lib/images/logo_crossnet.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Home',
                      style: _selectedIndex == 0
                          ? const TextStyle(
                              color: Color.fromARGB(255, 24, 41, 78),
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            )),
                ],
              ),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.business,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Assets',
                      style: _selectedIndex == 1
                          ? const TextStyle(
                              color: Color.fromARGB(255, 24, 41, 78),
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            )),
                ],
              ),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                goToPage(RentedDetails());
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.document_scanner,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Requests',
                      style: _selectedIndex == 2
                          ? const TextStyle(
                              color: Color.fromARGB(255, 24, 41, 78),
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            )),
                ],
              ),
              selected: _selectedIndex == 2,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RequestList(),
                  ),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Profile',
                      style: _selectedIndex == 3
                          ? const TextStyle(
                              color: Color.fromARGB(255, 24, 41, 78),
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            )),
                ],
              ),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Settings',
                      style: _selectedIndex == 4
                          ? const TextStyle(
                              color: Color.fromARGB(255, 24, 41, 78),
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            )),
                ],
              ),
              selected: _selectedIndex == 4,
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Log Out',
                      style: _selectedIndex == 5
                          ? const TextStyle(
                              color: Color.fromARGB(255, 24, 41, 78),
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            )),
                ],
              ),
              selected: _selectedIndex == 5,
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AssetsList extends StatefulWidget {
  const AssetsList({super.key});

  @override
  State<AssetsList> createState() => _AssetsListState();
}

class _AssetsListState extends State<AssetsList> {
  List<String> assetNames = [];
  List<int> assetID = [];
  List<String> assetAlamat = [];
  List<String> assetTipe = [];
  List<int> assetArea = [];
  List<int> assetValue = [];
  List<String> assetCondition = [];
  List<String> assetCoordinate = [];
  List<String> assetVerif = [];

  @override
  void initState() {
    super.initState();
    _fetchAssets();
    _loadRequests();
  }

  num totalReq = 0;

  Future<void> _loadRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print('userID di request: $userId');

    if (userId != null) {
      String baseUrl = 'http://leap.crossnet.co.id:1762';
      var url = Uri.parse('$baseUrl/tranreq/user/$userId');

      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body)['data'];

          print('data: $data');
          setState(() {
            totalReq += data.length + 1;
          });
          print('total req: $totalReq');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> _fetchAssets() async {
    String baseUrl = 'http://leap.crossnet.co.id:1762';
    var url = Uri.parse('$baseUrl/asset');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var assets = data['data'] as List;
        if (assets.isNotEmpty) {
          for (var asset in assets) {
            assetNames.add(asset['nama']);
            assetID.add(asset['id_asset']);
            assetAlamat.add(asset['alamat']);
            assetTipe.add(asset['tipe']);
            assetArea.add(asset['luas']);
            assetValue.add(asset['nilai']);
            assetCondition.add(asset['kondisi']);
            assetCoordinate.add(asset['titik_koordinat']);
            assetVerif.add(asset['status_verifikasi']);
            print('koordinatttt: $assetCoordinate');
            setState(() {
              assetNames = assetNames;
              assetID = assetID;
              assetAlamat = assetAlamat;
              assetTipe = assetTipe;
              assetArea = assetArea;
              assetValue = assetValue;
              assetCondition = assetCondition;
              assetCoordinate = assetCoordinate;
              assetVerif = assetVerif;
            });
          }
          print('Response data: $assetNames');
        } else {
          print('No assets found');
        }
      } else {
        print('Failed to load assets. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching assets: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Color.fromARGB(255, 242, 243, 247),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Requests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          GestureDetector(
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RequestList(),
                ),
              )
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 2, color: const Color.fromARGB(50, 24, 41, 78)),
                  borderRadius: BorderRadius.circular(10)),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner,
                    size: 48,
                    color: Color.fromARGB(255, 24, 41, 78),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Transaction Requests',
                    style: TextStyle(
                      color: Color.fromARGB(255, 24, 41, 78),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Total requests: 2'),
          ),
          const SizedBox(
            height: 32,
          ),
          const Divider(
            thickness: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assets',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchAssets(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Search Assets'),
                  ],
                ),
              )
            ],
          ),
          assetNames.isEmpty
              ? CircularProgressIndicator()
              : Container(
                  height: 180,
                  child: ListView.builder(
                    itemCount: assetNames.length > 2 ? 2 : assetNames.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Icon(
                              Icons.business,
                              color: Color.fromARGB(255, 24, 41, 78),
                              size: 48,
                            ),
                            title: Text(
                              assetNames[index],
                              style: TextStyle(
                                color: Color.fromARGB(255, 24, 41, 78),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(assetAlamat[index]),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailAssetComp(
                                    assetID: assetID[index],
                                    assetName: assetNames[index],
                                    location: assetAlamat[index],
                                    type: assetTipe[index],
                                    area: assetArea[index],
                                    value: assetValue[index],
                                    condition: assetCondition[index],
                                    coordinate: assetCoordinate[index],
                                    verification_status: assetVerif[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchAssets(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  List<Map<String, dynamic>> waiting = [];
  List<String> waitingDateList = [];
  List<String> waitingTimeList = [];

  List<Map<String, dynamic>> accepted = [];
  List<String> acceptedDateList = [];
  List<String> acceptedTimeList = [];

  List<Map<String, dynamic>> declined = [];
  List<String> declinedDateList = [];
  List<String> declinedTimeList = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    int? compId = prefs.getInt('perusahaan_id');
    // int compId = 1;
    print('userID di request: $userId');
    print('compID di request: $compId');

    if (userId != null) {
      String baseUrl = 'http://leap.crossnet.co.id:1762';
      var url = Uri.parse('$baseUrl/tranreq/user/$userId');

      try {
        var response = await http.get(url);
        print('Response code req: ${response.statusCode}');
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body)['data'];

          print('data: $data');

          for (var req in data) {
            if (req['perusahaan_id'] == compId) {
              if (req['status'] == 'W') {
                waiting.add(req);
                String dateTimeString = req['created_at'];
                DateTime dateTime = DateTime.parse(dateTimeString);
                String dateOnly =
                    "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
                String timeOnly =
                    "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                waitingDateList.add(dateOnly);
                waitingTimeList.add(timeOnly);
                setState(() {
                  waiting = waiting;
                  waitingDateList = waitingDateList;
                  waitingTimeList = waitingTimeList;
                });
                print('waiting with perusahaan id: $waiting');
              }
              if (req['status'] == 'A') {
                accepted.add(req);
                String dateTimeString = req['created_at'];
                DateTime dateTime = DateTime.parse(dateTimeString);
                String dateOnly =
                    "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
                String timeOnly =
                    "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                acceptedDateList.add(dateOnly);
                acceptedTimeList.add(timeOnly);
                setState(() {
                  accepted = accepted;
                  acceptedDateList = acceptedDateList;
                  acceptedTimeList = acceptedTimeList;
                });
              }
              if (req['status'] == 'D') {
                declined.add(req);
                String dateTimeString = req['created_at'];
                DateTime dateTime = DateTime.parse(dateTimeString);
                String dateOnly =
                    "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
                String timeOnly =
                    "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                declinedDateList.add(dateOnly);
                declinedTimeList.add(timeOnly);
                setState(() {
                  declined = declined;
                  declinedDateList = declinedDateList;
                  declinedTimeList = declinedTimeList;
                });
              }
            }
          }
        } else {
          print('Failed to load user data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 243, 247),
        padding: EdgeInsets.all(16),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                indicatorColor: Color.fromARGB(255, 24, 41, 78),
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 24, 41, 78),
                ),
                tabs: [
                  Tab(
                      child: Text(
                    'Waiting',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Tab(
                      child: Text(
                    'Accepted',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Tab(
                      child: Text(
                    'Declined',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Tab(
                      child: ListView.builder(
                        itemCount: waiting.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(waitingDateList[index]),
                                        Text(waitingTimeList[index]),
                                      ],
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      waiting[index]['nama_aset'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('Location: '),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Tab(
                      child: ListView.builder(
                        itemCount: accepted.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(acceptedDateList[index]),
                                        Text(acceptedTimeList[index]),
                                      ],
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      accepted[index]['nama_aset'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Location: ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Meeting Schedule',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            'Date: ${accepted[index]['tgl_meeting']}\nTime: ${accepted[index]['waktu_meeting']}\nPlace: ${accepted[index]['lokasi_meeting']}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Tab(
                      child: ListView.builder(
                        itemCount: declined.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(declinedDateList[index]),
                                        Text(declinedTimeList[index]),
                                      ],
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      declined[index]['nama_aset'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Location: ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 24, 41, 78),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reason',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            declined[index]['alasan'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

class ProfileList extends StatefulWidget {
  final companyId;
  final usernamePerusahaan;

  const ProfileList({super.key, this.usernamePerusahaan, this.companyId});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  List<dynamic> users = [];
  List usernames = [];

  @override
  void initState() {
    super.initState();
    _loadPerusahaanData();
  }

  Future<void> _loadPerusahaanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print('userID di profile: $userId');

    if (userId != null) {
      String baseUrl;

      baseUrl = 'http://leap.crossnet.co.id:1762';
      var url = Uri.parse('$baseUrl/perusahaan/detail/${widget.companyId}');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        if (data is Map<String, dynamic>) {
          setState(() {
            users = List<dynamic>.from(data['UserJoined'] ?? []);
            usernames = users
                .where((user) => user is Map<String, dynamic>)
                .map((user) =>
                    (user as Map<String, dynamic>)['username'] ?? 'Unknown')
                .toList();
            print('usernamesss: $usernames');
          });
        } else {
          print('Failed to load user data: ${response.statusCode}');
        }
      } else {
        print('User ID not found in SharedPreferences');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200.0,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Container(
                      height: 100.0,
                      color: const Color.fromARGB(255, 24, 41, 78),
                    ),
                    Container(
                      height: 100.0,
                      color: Color.fromARGB(255, 242, 243, 247),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.only(left: 48, right: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            )
                          ],
                          border: Border.all(
                            color: Colors.white,
                            width: 9.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'lib/images/foto.png',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 48,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  widget.usernamePerusahaan,
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Container(
                              height: 48,
                              child: const Text(
                                'Middle Class',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black54,
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
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 24),
          color: Color.fromARGB(255, 242, 243, 247),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Users',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(500, 24, 41, 78),
                ),
              )),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            color: Color.fromARGB(255, 242, 243, 247),
            height: 200,
            child: users.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: usernames.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Icon(
                              Icons.business,
                              color: Color.fromARGB(255, 24, 41, 78),
                              size: 48,
                            ),
                            title: Text(
                              usernames[index],
                              style: TextStyle(
                                color: Color.fromARGB(255, 24, 41, 78),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(usernames[index]), //role
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Color.fromARGB(255, 242, 243, 247),
              width: double.infinity,
              height: 100,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(500, 24, 41, 78),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => AddUser()));
                },
                child: const Text(
                  'Add User',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              color: Color.fromARGB(255, 242, 243, 247),
              width: double.infinity,
              height: 100,
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
                  'Link Company',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(500, 24, 41, 78),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class RentedDetails extends StatefulWidget {
  const RentedDetails({super.key});

  @override
  State<RentedDetails> createState() => _RentedDetailsState();
}

class _RentedDetailsState extends State<RentedDetails> {
  final List<String> boughtList = [
    'Gedung T',
  ];

  final List<String> rentedList = [
    'Gedung O',
    'Gedung D',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rented',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Color.fromARGB(255, 242, 243, 247),
        width: double.infinity,
        height: double.infinity,
        child: rentedList.isEmpty
            ? Center(
                child: Text('No asset',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
            : ListView.builder(
                itemCount: rentedList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                          rentedList[index],
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Jalan blablabla'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                    Text('User ID', style: TextStyle(fontSize: 18)),
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
                    Text('Name', style: TextStyle(fontSize: 18)),
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
                    Text('Privilege', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      items: [
                        DropdownMenuItem(
                          value: 'Admin',
                          child: Text('Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'Staff',
                          child: Text('Staff'),
                        ),
                        DropdownMenuItem(
                          value: 'Director',
                          child: Text('Director'),
                        ),
                      ],
                      onChanged: (value) {
                        // Handle change here
                      },
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
                        onPressed: () {},
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

class LinkCompany extends StatefulWidget {
  const LinkCompany({super.key});

  @override
  State<LinkCompany> createState() => _LinkCompanyState();
}

class _LinkCompanyState extends State<LinkCompany> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                    Text('Company ID', style: TextStyle(fontSize: 18)),
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
                    Text('Privilege', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      items: [
                        DropdownMenuItem(
                          value: 'Admin',
                          child: Text('Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'Staff',
                          child: Text('Staff'),
                        ),
                        DropdownMenuItem(
                          value: 'Director',
                          child: Text('Director'),
                        ),
                      ],
                      onChanged: (value) {
                        // Handle change here
                      },
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
                        onPressed: () {},
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

class NotificationList extends StatefulWidget {
  NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<String> title = [];
  List<String> dateList = [];
  List<String> timeList = [];
  List<String> notifDetail = [];

  @override
  void initState() {
    _getNotifications();
    super.initState();
  }

  Future<void> _getNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    String baseUrl = 'http://leap.crossnet.co.id:1762';
    var url = Uri.parse('$baseUrl/notification/receiver/$userId');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var notifs = data['data'] as List;

        if (notifs.isNotEmpty) {
          for (var notif in notifs) {
            title.add(notif['notification_title']);

            String dateTimeString = notif['created_at'];
            DateTime dateTime = DateTime.parse(dateTimeString);

            String dateOnly =
                "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
            String timeOnly =
                "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

            dateList.add(dateOnly);
            timeList.add(timeOnly);
            notifDetail.add(notif['notification_detail']);

            setState(() {
              title = title;
              dateList = dateList;
              timeList = timeList;
              notifDetail = notifDetail;
            });
          }
        } else {
          print('No notifications found');
        }
      } else {
        print(
            'Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching notifications: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 243, 247),
        child: Expanded(
          child: ListView.builder(
            itemCount: title.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  border: Border(
                    bottom: BorderSide(
                      color: index == title.length - 1
                          ? Colors.transparent
                          : Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    dateList[index],
                    // 'date',
                    style: TextStyle(
                      color: Color.fromARGB(255, 24, 41, 78),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title[index]),
                      Text(notifDetail[index]),
                    ],
                  ),
                  trailing: Text(timeList[index]),
                  leading: Icon(Icons.info_outline),
                  onTap: () {
                    // Handle tap
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
