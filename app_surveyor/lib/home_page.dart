// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:io';

import 'package:app_surveyor/detail_surveys.dart';
import 'package:app_surveyor/login_page.dart';
import 'package:app_surveyor/search_history.dart';
import 'package:app_surveyor/search_survey.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  Map<String, dynamic>? userData;
  int? userId = 0;

  List<dynamic> ongoing = [];
  List<dynamic> history = [];

  List<int> OGid = [];
  List<String> OGnama = [];
  List<String> OGalamat = [];

  List<int> historyId = [];
  List<String> historyNama = [];
  List<String> historyAlamat = [];

  int totalOG = 0;
  int totalDone = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
    print('userID: $userId');

    if (userId != null) {
      var url = Uri.parse('$baseUrl/surveyor/user/$userId');
      print('url user: $url');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        setState(() {
          userData = data;
        });
        print('Data fetched');
        _loadOngoingAssignment();
        _loadHistoryAssignment();
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> _loadOngoingAssignment() async {
    if (userId != 0) {
      var url = Uri.parse('$baseUrl/survey_req/ongoing/$userId');
      var response = await http.get(url);
      print('url: $url');
      print('userid load ongoing: $userId');
      print('load ongoing: ${response.statusCode}');

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        totalOG = datas.length;
        print('totalOG: $totalOG');

        OGid.clear();
        OGnama.clear();
        OGalamat.clear();

        for (var data in datas) {
          OGid.add(data['id_asset']);
        }

        for (var id in OGid) {
          await _loadAssetOG(id);
        }

        print('OG id : $OGid');
        print('OG nama : $OGnama');
        print('OG alamat : $OGalamat');
      } else {
        print('Response code error');
      }
    }
  }

  Future<void> _loadHistoryAssignment() async {
    if (userId != 0) {
      var url = Uri.parse('$baseUrl/survey_req/finished/$userId');
      var response = await http.get(url);
      print('url: $url');
      print('userid load history: $userId');
      print('load history: ${response.statusCode}');

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        totalDone = datas.length;
        print('totalDone: $totalDone');

        historyId.clear();
        historyNama.clear();
        historyAlamat.clear();

        for (var data in datas) {
          historyId.add(data['id_asset']);
        }

        for (var id in historyId) {
          await _loadAssetHistory(id);
        }

        print('history id : $historyId');
        print('history nama : $historyNama');
        print('history alamat : $historyAlamat');
      } else {
        print('Response code error');
      }
    }
  }

  Future<void> _loadAssetHistory(int historyID) async {
    var url = Uri.parse('$baseUrl/asset/$historyID');
    var response = await http.get(url);
    print('url new: $url');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      historyNama.add(data['nama']);
      historyAlamat.add(data['alamat']);
    } else {
      print('Response code error: ${response.statusCode}');
    }
  }

  Future<void> _loadAssetOG(int ogID) async {
    var url = Uri.parse('$baseUrl/asset/$ogID');
    var response = await http.get(url);
    print('url new: $url');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      OGnama.add(data['nama']);
      OGalamat.add(data['alamat']);
    } else {
      print('Response code error: ${response.statusCode}');
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
      SurveysList(
        surveysId: OGid,
        surveysNama: OGnama,
        surveysAlamat: OGalamat,
        historyId: historyId,
        historyNama: historyNama,
        historyAlamat: historyAlamat,
      ),
      const AssignmentstList(),
      Profile(
        userData: userData,
        totalOG: totalOG,
        totalDone: totalDone,
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
                    Icons.history,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Surveys',
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
                    Icons.document_scanner,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 24, 41, 78)
                        : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text('Assignments',
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
                // _onItemTapped(1);
                // Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AssignmentstList(),
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
                _onItemTapped(2);
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
              selected: _selectedIndex == 3,
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

class SurveysList extends StatefulWidget {
  final surveysId;
  final surveysNama;
  final surveysAlamat;

  final historyId;
  final historyNama;
  final historyAlamat;
  const SurveysList(
      {super.key,
      this.surveysNama,
      this.surveysAlamat,
      this.historyNama,
      this.historyAlamat,
      this.surveysId,
      this.historyId});

  @override
  State<SurveysList> createState() => _SurveysListState();
}

class _SurveysListState extends State<SurveysList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Color.fromARGB(255, 242, 243, 247),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assignments',
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
                    builder: (context) => SearchSurvey(),
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
                      'Check Assignments',
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Total assignments: 2'),
            ),
            const SizedBox(height: 32),
            const Divider(thickness: 2),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surveys',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchSurvey(),
                      ),
                    );
                    print('goto');
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
                      Text('Search Surveys'),
                    ],
                  ),
                )
              ],
            ),
            Container(
              height: 90,
              child: ListView.builder(
                itemCount: widget.surveysNama.length > 1
                    ? 1
                    : widget.surveysNama.length,
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
                          widget.surveysNama[index],
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(widget.surveysAlamat[index]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailSurveys(
                                assetId: widget.surveysId[index],
                                assetName: widget.surveysNama[index],
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
                      builder: (context) => SearchSurvey(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchHistory(),
                      ),
                    );
                    print('goto');
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
                      Text('Search History'),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 90,
              child: ListView.builder(
                itemCount: widget.historyNama.length > 1
                    ? 1
                    : widget.historyNama.length,
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
                          widget.historyNama[index],
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                            'View assets for ${widget.historyAlamat[index]}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistorySurveys(
                                assetId: widget.historyId[index],
                                assetName: widget.historyNama[index],
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
                      builder: (context) => SearchHistory(),
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
      ),
    );
  }
}

class AssignmentstList extends StatefulWidget {
  const AssignmentstList({super.key});

  @override
  State<AssignmentstList> createState() => _AssignmentstListState();
}

class _AssignmentstListState extends State<AssignmentstList> {
  final List<String> companyProfiles = [
    'Company Profile 1',
    'Company Profile 2',
    'Company Profile 3',
    'Company Profile 4',
    'Company Profile 5',
    'Company Profile 6',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 243, 247),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: TextField(
                  onChanged: (value) {
                    // _searchResep(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search Assignment',
                    hintStyle: TextStyle(fontSize: 16.0),
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: companyProfiles.length,
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
                          'Name: ${companyProfiles[index]}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Coordinate: \nLocation: \nDateline: '),
                        trailing: Icon(Icons.download),
                        onTap: () {
                          // Handle tap
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Profile extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final totalOG;
  final totalDone;

  Profile({super.key, this.userData, this.totalOG, this.totalDone});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<DateTime> deadlines = [
    DateTime(DateTime.now().year, 8, 10), // August 10
    DateTime(DateTime.now().year, 8, 25), // August 25
  ];
  bool isDeadline(DateTime date) {
    // Compare only the year, month, and day
    return deadlines.any((deadline) =>
        date.year == deadline.year &&
        date.month == deadline.month &&
        date.day == deadline.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          color: Colors.transparent,
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
                                Container(
                                  height: 48,
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black54,
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
              padding: const EdgeInsets.only(left: 48, right: 48),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchSurvey(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.totalOG.toString(),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 24, 41, 78),
                                    ),
                                  ),
                                  Text(
                                    'surveys ongoing',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 24, 41, 78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchHistory(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.totalDone.toString(),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 24, 41, 78),
                                    ),
                                  ),
                                  Text(
                                    'surveys done',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 24, 41, 78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Datelines',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 24, 41, 78),
                        )),
                  ),
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: DateTime.now(),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, focusedDay) {
                        if (isDeadline(date)) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 24, 41, 78),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
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
