// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:app_user/company_home_page.dart';
import 'package:app_user/company_request.dart';
import 'package:app_user/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    userId = prefs.getInt('user_id');
    setState(() {
      userId = userId;
    });

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
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } else {
      print('User ID not found in SharedPreferences');
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
      ProfileList(userData: userData),
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
                'Hello, ${userData?['nama_lengkap']}',
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
  num totalReq = 0;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

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
            totalReq += data.length;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            child:
                // totalReq == null ? Center(child: CircularProgressIndicator()) :
                Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: const Color.fromARGB(50, 24, 41, 78),
                  ),
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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Total requests: $totalReq'),
          ),
          const SizedBox(height: 32),
          const Divider(thickness: 2),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  color: Color.fromARGB(255, 24, 41, 78),
                  size: 96,
                ),
                Text(
                  'Please choose a company profile to view assets',
                  style: TextStyle(
                    color: Color.fromARGB(255, 24, 41, 78),
                  ),
                ),
              ],
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

  bool isLoadingData1 = true;
  bool isLoadingData2 = true;
  bool isLoadingData3 = true;

  bool isEmptyData1 = false;
  bool isEmptyData2 = false;
  bool isEmptyData3 = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      isLoadingData1 = true;
      isLoadingData2 = true;
      isLoadingData3 = true;
    });
    await Future.delayed(Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print('userID di request: $userId');

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
            if (req['status'] == 'W') {
              if (req.isNotEmpty) {
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
                  isLoadingData1 = false;
                  isEmptyData1 = waiting.isEmpty;
                });
              } else {
                setState(() {
                  isEmptyData1 = waiting.isEmpty;
                });
              }
            }
            if (req['status'] == 'A') {
              if (req.isNotEmpty) {
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
                  isLoadingData2 = false;
                  isEmptyData2 = accepted.isEmpty;
                });
                print('accepted: $accepted');
              } else {
                setState(() {
                  isEmptyData2 = accepted.isEmpty;
                });
              }
            }
            if (req['status'] == 'D') {
              if (req.isNotEmpty) {
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
                  isLoadingData3 = false;
                  isEmptyData3 = declined.isEmpty;
                });
              } else {
                setState(() {
                  isEmptyData2 = accepted.isEmpty;
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
                      child: isLoadingData1
                          ? Center(child: CircularProgressIndicator())
                          : isEmptyData1
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: waiting.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    color: Color.fromARGB(
                                                        255, 24, 41, 78),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  'Location: ${waiting[index]['lokasi_perusahaan']}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                    Tab(
                      child: isLoadingData2
                          ? Center(child: CircularProgressIndicator())
                          : isEmptyData2
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: accepted.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    color: Color.fromARGB(
                                                        255, 24, 41, 78),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                accepted[index]
                                                    ['lokasi_perusahaan'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 24, 41, 78),
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 24, 41, 78),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Meeting Schedule',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                      child: isLoadingData3
                          ? Center(child: CircularProgressIndicator())
                          : isEmptyData3
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: declined.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    color: Color.fromARGB(
                                                        255, 24, 41, 78),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                declined[index]
                                                    ['lokasi_perusahaan'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 24, 41, 78),
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 24, 41, 78),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Reason',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
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
  final Map<String, dynamic>? userData;
  const ProfileList({super.key, this.userData});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  List<dynamic>? perusahaanData;

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
      String baseUrl = 'http://leap.crossnet.co.id:1762';
      var url = Uri.parse('$baseUrl/perusahaan/user/$userId');

      try {
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body)['data'];

          if (data != null) {
            setState(() {
              perusahaanData = data;
            });
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

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
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
                      // color: Colors.transparent,
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
                                  // 'Profile',
                                  '${widget.userData!['nama_lengkap']}',
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                goToPage(EditProfile());
                              },
                              child: Container(
                                height: 48,
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black54,
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
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 24),
          color: Color.fromARGB(255, 242, 243, 247),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Companies',
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
            child: ListView.builder(
              itemCount: perusahaanData?.length ?? 0,
              itemBuilder: (context, index) {
                if (index >= perusahaanData!.length) {
                  return SizedBox.shrink();
                }
                var detail = perusahaanData![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        detail['nama'] ?? '',
                        style: TextStyle(
                          color: Color.fromARGB(255, 24, 41, 78),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        detail['lokasi'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color.fromARGB(500, 24, 41, 78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CompanyHomePage(
                                companyId: detail['id_perusahaan'],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'LOGIN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompanyHomePage(
                    companyId: 1,
                  ),
                ),
              );
            },
            child: Text('skip to comp')),
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompanyRequest(),
                ),
              );
            },
            child: const Text(
              'Request Company',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  int? userID = 0;

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  void _saveProfile() async {
    print('pressed saveProfile');
    String url = 'http://leap.crossnet.co.id:1762/user/';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    setState(() {
      userID = userId;
    });

    print('userid in edit: $userId');

    final Map<String, dynamic> body = {
      "user_id": userId,
      "full_name": _nameController.text,
      "username": _usernameController.text,
      "email": _emailController.text,
      "phone_number": _phoneController.text,
      "alamat": _alamatController.text,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Profile updated successfully");
      Navigator.of(context).pop();
    } else {
      print("Failed to update profile: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 41, 78),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(70),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 242, 243, 247),
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
                              Text('Edit Profile Picture'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      enabled: false,
                      cursorColor: const Color.fromARGB(500, 24, 41, 78),
                      style: TextStyle(
                        color: Color.fromARGB(500, 24, 41, 78),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: userID.toString(),
                        suffixIcon: Icon(Icons.edit),
                        suffixIconColor: Color.fromARGB(500, 24, 41, 78),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(500, 24, 41, 78),
                          ),
                        ),
                      ),
                    ),
                    formFieldTemplate(
                        textTitle: 'Full Name', controller: _nameController),
                    formFieldTemplate(
                        textTitle: 'Username', controller: _usernameController),
                    formFieldTemplate(
                        textTitle: 'Email', controller: _emailController),
                    formFieldTemplate(
                        textTitle: 'Phone Number',
                        controller: _phoneController),
                    formFieldTemplate(
                        textTitle: 'Alamat', controller: _alamatController),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      color: Color.fromARGB(255, 242, 243, 247),
                      width: double.infinity,
                      height: 100,
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
                          _saveProfile();
                        },
                        child: const Text(
                          'SAVE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget formFieldTemplate({
  required String textTitle,
  required TextEditingController controller,
  bool isStyle = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8),
      TextFormField(
        controller: controller,
        cursorColor: const Color.fromARGB(500, 24, 41, 78),
        style: TextStyle(
          color: Color.fromARGB(500, 24, 41, 78),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: textTitle,
          suffixIcon: Icon(Icons.edit),
          suffixIconColor: Color.fromARGB(500, 24, 41, 78),
          labelStyle: TextStyle(
            color: Color.fromARGB(500, 24, 41, 78),
            fontWeight: isStyle ? FontWeight.bold : FontWeight.normal,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Color.fromARGB(500, 24, 41, 78),
            ),
          ),
        ),
      ),
      SizedBox(height: 8),
    ],
  );
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

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

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
    );
  }
}
