// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, prefer_typing_uninitialized_variables, use_build_context_synchronously
import 'dart:io';

import 'package:surveyor/detail_surveys.dart';
import 'package:surveyor/login_page.dart';
import 'package:surveyor/search_history.dart';
import 'package:surveyor/search_survey.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  int totalOG = 0;
  int totalDone = 0;

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

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        setState(() {
          totalOG = datas.length;
        });
        print('totalOG: $totalOG');
      } else {
        print('Response code error');
      }
    }
  }

  Future<void> _loadHistoryAssignment() async {
    if (userId != 0) {
      var url = Uri.parse('$baseUrl/survey_req/finished/$userId');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        setState(() {
          totalDone = datas.length;
        });
        print('totalDone: $totalDone');
      } else {
        print('Response code error');
      }
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
      SurveysList(),
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
  // final surveysId;
  // final surveyTransId;
  // final surveysNama;
  // final surveysAlamat;
  // final isLoadingOG;
  // final ogEmpty;

  // final historyId;
  // final historyNama;
  // final historyAlamat;
  // final isLoadingHistory;
  // final historyEmpty;
  const SurveysList({
    super.key,
    // this.surveysNama,
    // this.surveysAlamat,
    // this.historyNama,
    // this.historyAlamat,
    // this.surveysId,
    // this.historyId,
    // this.isLoadingOG,
    // this.isLoadingHistory,
    // this.ogEmpty,
    // this.historyEmpty,
    // this.surveyTransId,
  });

  @override
  State<SurveysList> createState() => _SurveysListState();
}

class _SurveysListState extends State<SurveysList> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';

  List<int> OGid = [];
  List<int> OGAssetId = [];
  List<String> OGnama = [];
  List<String> OGalamat = [];

  List<int> historyId = [];
  List<String> historyNama = [];
  List<String> historyAlamat = [];

  bool isLoadingOG = true;
  bool OGEmpty = false;

  bool isLoadingHistory = true;
  bool historyEmpty = false;

  int totalOG = 0;
  int totalDone = 0;

  @override
  void initState() {
    super.initState();
    _loadOngoingAssignment();
    _loadHistoryAssignment();
  }

  Future<void> _loadOngoingAssignment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != 0) {
      setState(() {
        isLoadingOG = true;
      });

      var url = Uri.parse('$baseUrl/survey_req/ongoing/$userId');
      var response = await http.get(url);
      print('url: $url');
      print('userid load ongoing: $userId');
      print('load ongoing: ${response.statusCode}');

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        totalOG = datas.length;
        print('totalOG: $totalOG');

        if (totalOG != 0) {
          setState(() {
            for (var data in datas) {
              OGid.add(data['id_transaksi_jual_sewa']);
              OGAssetId.add(data['id_asset']);
              OGnama.add(data['asset_nama']);
              OGalamat.add(data['asset_alamat']);
            }
            isLoadingOG = false;
          });
          print('id asset: $OGid');
        } else {
          isLoadingOG = false;
          OGEmpty = true;
        }
      } else {
        OGEmpty = OGid.isEmpty;
        print('Response code error');
      }
    }
  }

  Future<void> _loadHistoryAssignment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != 0) {
      setState(() {
        isLoadingHistory = true;
      });

      var url = Uri.parse('$baseUrl/survey_req/finished/$userId');
      var response = await http.get(url);
      print('url: $url');
      print('userid load history: $userId');
      print('load history: ${response.statusCode}');

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        totalDone = datas.length;
        print('totalDone: $totalDone');

        if (totalDone != 0) {
          setState(() {
            for (var data in datas) {
              historyId.add(data['id_asset']);
              historyNama.add(data['asset_nama']);
              historyAlamat.add(data['asset_alamat']);
            }
            isLoadingHistory = false;
          });
        } else {
          isLoadingHistory = false;
          historyEmpty = true;
        }
      } else {
        historyEmpty = historyId.isEmpty;
        print('Response code error');
      }
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Total assignments: $totalOG'),
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
              child: isLoadingOG
                  ? Center(child: CircularProgressIndicator())
                  : OGEmpty
                      ? Center(child: Text('No Surveys'))
                      : ListView.builder(
                          itemCount: OGnama.length > 1 ? 1 : OGnama.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                    OGnama[index],
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 24, 41, 78),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(OGalamat[index]),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailSurveys(
                                          transId: OGid[index],
                                          assetId: OGAssetId[index],
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
              child: isLoadingHistory
                  ? Center(child: CircularProgressIndicator())
                  : historyEmpty
                      ? Center(child: Text('No History'))
                      : ListView.builder(
                          itemCount:
                              historyNama.length > 1 ? 1 : historyNama.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                    historyNama[index],
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 24, 41, 78),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('${historyAlamat[index]}'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistorySurveys(
                                          assetId: historyId[index],
                                          assetName: historyNama[index],
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
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  List<int> idTrans = [];
  List<String> namaAsset = [];
  List<String> locationAsset = [];
  List<String> dateLine = [];
  List<String> suratPenugasan = [];
  List<String> createdAtDate = [];
  List<String> createdAtTime = [];

  String? _downloadPath;

  @override
  void initState() {
    super.initState();
    _getAssignment();
    _initDownloadPath();
  }

  Future<void> _getAssignment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    var url = Uri.parse('$baseUrl/survey_req/user/$userId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      var dataMap = decodedResponse['data'];

      if (dataMap is Map<String, dynamic> &&
          dataMap['ongoing_assignment'] is List) {
        var ongoingAssignments = dataMap['ongoing_assignment'];

        for (var data in ongoingAssignments) {
          if (data['surat_penugasan'] != null &&
              data['surat_penugasan'].isNotEmpty) {
            var dateTime = data['created_at'];
            List<String> parts = dateTime.split(' ');

            String date = parts[0];
            String time = parts[1].substring(0, 5);

            setState(() {
              idTrans.add(data['id_transaksi_jual_sewa']);
              namaAsset.add(data['asset_nama']);
              locationAsset.add(data['asset_alamat']);
              dateLine.add(data['dateline']);
              createdAtDate.add(date);
              createdAtTime.add(time);
              suratPenugasan.add(data['surat_penugasan']);
            });
          }
        }
      } else {
        print(
            'Expected a List for ongoing_assignment but got: ${dataMap['ongoing_assignment'].runtimeType}');
      }
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> _initDownloadPath() async {
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    _downloadPath = downloadsDir.path;
    print('Download path: $_downloadPath');
  }

  Future<void> _downloadFile(String filePath) async {
    final downloadUrl = "$baseUrl/file?path=$filePath";

    print('download url: $downloadUrl');

    var data = await http.get(Uri.parse(downloadUrl));
    var bytes = data.bodyBytes;
    var dir = _downloadPath;
    File file = File("${dir}/another.pdf");
    await file.writeAsBytes(bytes);
  }

  // Future<void> _initDownloadPath() async {
  //   Directory? downloadsDir = await getExternalStorageDirectory();
  //   _downloadPath =
  //       "${downloadsDir!.path}/Download"; // Use path_provider to get the correct download path
  //   print('Download path: $_downloadPath');

  //   // Create the download directory if it doesn't exist
  //   final downloadDirectory = Directory(_downloadPath!);
  //   if (!await downloadDirectory.exists()) {
  //     await downloadDirectory.create(recursive: true);
  //   }
  // }

  // Future<void> _requestPermission() async {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  // }

  // Future<void> _downloadFile(String filePath) async {
  //   await _requestPermission();
  //   final downloadUrl = "$baseUrl/file?path=$filePath";

  //   print('Download URL: $downloadUrl');

  //   try {
  //     var response = await http.get(Uri.parse(downloadUrl));

  //     if (response.statusCode == 200) {
  //       var bytes = response.bodyBytes;
  //       File file = File("$_downloadPath/baru.pdf");
  //       await file.writeAsBytes(bytes);
  //       print('File downloaded successfully: ${file.path}');
  //     } else {
  //       print('Error downloading file: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Download error: $e');
  //   }
  // }

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
                itemCount: idTrans.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(createdAtDate[index]),
                                Text(createdAtTime[index]),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Name: ${namaAsset[index]}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Location: ${locationAsset[index]}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Dateline: ${dateLine[index]}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                print(
                                    'suratpenugasan: ${suratPenugasan[index]}');
                                _downloadFile(suratPenugasan[index]);
                                // _downloadFile(
                                // 'uploads/survey_req/surat/18_undergraduate.pdf');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 242, 243, 247),
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Color.fromARGB(500, 24, 41, 78),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf),
                                        SizedBox(width: 8),
                                        Text(
                                          'Letter of Assignment',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(500, 24, 41, 78),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.download)
                                  ],
                                ),
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
    );
  }
}

class AssetData {
  int idAsset;
  DateTime dateline;

  AssetData({required this.idAsset, required this.dateline});

  factory AssetData.fromJson(Map<String, dynamic> json) {
    return AssetData(
      idAsset: json['id_asset'],
      dateline: DateTime.parse(json['dateline']),
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
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  int? userId = 0;
  int transId = 0;

  String? selectedValue;

  List<String> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, int> eventDetails = {};

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    fetchEventDetails().then((details) {
      setState(() {
        eventDetails = details;
      });
    }).catchError((error) {
      print(error);
    });
    _getAvailability();
  }

  Future<void> _getAvailability() async {
    print('id: ${widget.userData!['user_id']}');
    print('avail: ${widget.userData!['availability_surveyor']}');
    if (widget.userData!['availability_surveyor'] == "Y") {
      setState(() {
        selectedValue = 'Available';
      });
    } else {
      setState(() {
        selectedValue = 'Unavailable';
      });
    }
  }

  void _changeAvail(String val) async {
    int userid = widget.userData!['surveyor_id'];
    String url = '$baseUrl/surveyor/avail';

    String yn = '';

    if (val == 'Available') {
      yn = 'Y';
    } else {
      yn = 'N';
    }

    print('yn in ava: $yn');
    print('survid in ava: $userid');

    final Map<String, dynamic> body = {
      "surveyor_id": userid,
      "availability": yn,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('body: ${response.body}');
      print('changed');
    } else {
      print("Failed to update profile: ${response.reasonPhrase}");
    }
  }

  Future<Map<DateTime, int>> fetchEventDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    final response =
        await http.get(Uri.parse('$baseUrl/survey_req/ongoing/$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      Map<DateTime, int> eventDetails = {};

      for (var item in data) {
        String dateString = item['dateline'];
        DateTime dateTime = DateTime.parse(dateString);
        int idAsset = item['id_asset'];
        transId = item['id_transaksi_jual_sewa'];

        eventDetails[dateTime] = idAsset;
      }
      print('eventDetails: $eventDetails');

      return eventDetails;
    } else {
      throw Exception('Failed to load event details');
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
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
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
                    child: Text('Status',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 24, 41, 78),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.3,
                            child: Radio<String>(
                              value: 'Available',
                              groupValue: selectedValue,
                              activeColor: Colors.green,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValue = value;
                                  _changeAvail(value!);
                                });
                              },
                            ),
                          ),
                          Text(
                            'Available',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.3,
                            child: Radio<String>(
                              value: 'Unavailable',
                              groupValue: selectedValue,
                              activeColor: Colors.red,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValue = value;
                                  _changeAvail(value!);
                                });
                              },
                            ),
                          ),
                          Text(
                            'Unavailable',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
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
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: _selectedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _selectedEvents = _getEventsForDay(selectedDay);
                      });

                      // Check if the selected day has an event
                      if (eventDetails.containsKey(selectedDay)) {
                        // int idAsset = eventDetails[selectedDay]!;
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         DetailSurveys(assetId: idAsset),
                        //   ),
                        // );
                      }
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        bool isEventDay = eventDetails.keys
                            .any((eventDay) => isSameDate(eventDay, day));
                        int? idAsset;

                        if (isEventDay) {
                          idAsset = eventDetails.entries
                              .firstWhere((entry) => isSameDate(entry.key, day))
                              .value;
                        }

                        return GestureDetector(
                          onTap: () {
                            if (idAsset != null) {
                              print(
                                  "Navigating to DetailSurveys with assetId: $idAsset");
                              // goToPage(DetailSurveys(assetId: idAsset));
                            } else {
                              print("idAsset is null for the date: $day");
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color:
                                  isEventDay ? Colors.green : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            width: 48.0,
                            height: 48.0,
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: isEventDay ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: 48.0,
                          height: 48.0,
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 24, 41, 78),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: 48.0,
                          height: 48.0,
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
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

  List<String> _getEventsForDay(DateTime day) {
    return eventDetails.containsKey(day) ? [eventDetails[day]!.toString()] : [];
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
  final TextEditingController _passwordController = TextEditingController();

  String baseUrl = 'http://leap.crossnet.co.id:1762';

  int? userID = 0;
  Image? profilePic;
  PlatformFile? fileFoto;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  void goToPage(Widget destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => destination,
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        fileFoto = result.files.first;
      });
    }
  }

  Future<void> _getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    setState(() {
      userID = userId;
    });

    print('userID in edit: $userID');

    if (userId != null) {
      var url = Uri.parse('$baseUrl/surveyor/user/$userId');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        print('edit data: $data');
        setState(() {
          _nameController.text = data['nama_lengkap'];
          _usernameController.text = data['username'];
          _emailController.text = data['email'];
          _phoneController.text = data['no_telp'];
          _passwordController.text = data['password'];
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  // Future<void> _saveProfile() async {
  //   if (fileFoto == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Please upload image!'),
  //     ));
  //     return;
  //   }

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int? userId = prefs.getInt('user_id');
  //   print('userId: $userId');

  //   // String apiUrl = '$baseUrl/user/id';
  //   var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));

  //   request.fields['id'] = userId.toString();
  //   request.fields['nama_lengkap'] = _nameController.text;
  //   request.fields['username'] = _usernameController.text;
  //   request.fields['email'] = _emailController.text;
  //   request.fields['no_telp'] = _phoneController.text;
  //   request.fields['password'] = _passwordController.text;

  //   if (fileFoto != null) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         'fileFoto',
  //         fileFoto!.path!,
  //         filename: fileFoto!.name,
  //       ),
  //     );
  //     print('request files: ${request.files.length}');
  //   } else {
  //     print("No dokumen file selected.");
  //   }

  //   var response = await request.send();
  //   print('response code pic: ${response.statusCode}');

  //   if (response.statusCode == 200) {
  //     var responseBody = await response.stream.bytesToString();
  //     print('Upload Successful: $responseBody');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Profile updated successfully'),
  //     ));
  //     Navigator.of(context).pop();
  //   } else {
  //     print('Upload failed with status: ${response.statusCode}');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Profile update failed'),
  //     ));
  //   }
  // }

  void _saveProfile() async {
    print('pressed saveProfile');
    String url = '$baseUrl/surveyor/user';

    print('userid in edit: $userID');

    final Map<String, dynamic> body = {
      "user_id": userID,
      "nama": _nameController.text,
      "username": _usernameController.text,
      "email": _emailController.text,
      "notelp": _phoneController.text,
      "password": _passwordController.text,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('body: $body');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
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
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                child: Column(
                  children: [
                    Text(
                      'ID',
                      style: TextStyle(
                        color: Color.fromARGB(500, 24, 41, 78),
                      ),
                    ),
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
                        textTitle: 'Password', controller: _passwordController),
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
      Text(
        textTitle,
        style: TextStyle(
          color: Color.fromARGB(500, 24, 41, 78),
        ),
      ),
      TextFormField(
        controller: controller,
        cursorColor: const Color.fromARGB(500, 24, 41, 78),
        style: TextStyle(
          color: Color.fromARGB(100, 24, 41, 78),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          // labelText: textTitle,
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

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';
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

    var url = Uri.parse('$baseUrl/notification/user/$userId');

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
