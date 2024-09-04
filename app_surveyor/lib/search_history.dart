// ignore_for_file: prefer_const_constructors

import 'package:app_surveyor/detail_surveys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchHistory extends StatefulWidget {
  const SearchHistory({super.key});

  @override
  State<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  Map<String, dynamic>? userData;
  int? userId; // Use null to represent an uninitialized state

  List<int> historyId = [];
  List<String> historyNama = [];
  List<String> historyAlamat = [];

  List<String> filteredHistory = [];

  @override
  void initState() {
    super.initState();
    filteredHistory =
        List.from(historyNama); // Ensure historyNama is initialized
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
        _loadHistoryAssignment();
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> _loadHistoryAssignment() async {
    if (userId != null && userId != 0) {
      var url = Uri.parse('$baseUrl/survey_req/finished/$userId');
      var response = await http.get(url);
      print('url: $url');
      print('userid load history: $userId');
      print('load history: ${response.statusCode}');

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

        historyId.clear();
        historyNama.clear();
        historyAlamat.clear();

        for (var data in datas) {
          historyId.add(data['id_asset']);
        }

        // Fetch details for each asset ID
        for (var id in historyId) {
          await _loadAssetHistory(id);
        }

        print('history id : $historyId');
        print('history nama : $historyNama');
        print('history alamat : $historyAlamat');

        setState(() {
          filteredHistory = List.from(historyNama);
        });
      } else {
        print('Response code error: ${response.statusCode}');
      }
    }
  }

  Future<void> _loadAssetHistory(int historyID) async {
    var url = Uri.parse('$baseUrl/asset/$historyID');
    var response = await http.get(url);
    print('url new: $url');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      if (mounted) {
        setState(() {
          historyNama.add(data['nama']);
          historyAlamat.add(data['alamat']);
        });
      }
    } else {
      print('Response code error: ${response.statusCode}');
    }
  }

  void _searchHistory(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          filteredHistory = List.from(historyNama);
        });
      }
    } else {
      final results = historyNama
          .where(
              (profile) => profile.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (mounted) {
        setState(() {
          filteredHistory = results;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        height: double.infinity,
        color: Color.fromARGB(255, 242, 243, 247),
        child: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 242, 243, 247),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: TextField(
                        onChanged: _searchHistory,
                        decoration: const InputDecoration(
                          hintText: 'Search History Survey',
                          hintStyle: TextStyle(fontSize: 16.0),
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredHistory.length,
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
                          filteredHistory[index],
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle:
                            Text('View assets for ${filteredHistory[index]}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistorySurveys(
                                assetId: historyId[index],
                                assetName: filteredHistory[index],
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
          ],
        ),
      ),
    );
  }
}
