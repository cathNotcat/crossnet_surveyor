// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:app_surveyor/detail_surveys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchSurvey extends StatefulWidget {
  const SearchSurvey({super.key});

  @override
  State<SearchSurvey> createState() => _SearchSurveyState();
}

class _SearchSurveyState extends State<SearchSurvey> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  Map<String, dynamic>? userData;
  int? userId;
  List<int> OGid = [];
  List<String> OGnama = [];
  List<String> OGalamat = [];
  List<String> filteredProfiles = [];

  @override
  void initState() {
    super.initState();
    filteredProfiles = List.from(OGnama);
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
        if (mounted) {
          setState(() {
            userData = data;
          });
        }
        print('Data fetched');

        _loadOngoingAssignment();
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  Future<void> _loadOngoingAssignment() async {
    if (userId != null && userId != 0) {
      var url = Uri.parse('$baseUrl/survey_req/ongoing/$userId');
      var response = await http.get(url);
      print('url: $url');
      print('userid load ongoing: $userId');
      print('load ongoing: ${response.statusCode}');

      if (response.statusCode == 200) {
        var datas = jsonDecode(response.body)['data'];

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
        if (mounted) {
          setState(() {
            filteredProfiles = List.from(OGnama);
          });
        }
      } else {
        print('Response code error: ${response.statusCode}');
      }
    }
  }

  Future<void> _loadAssetOG(int ogID) async {
    var url = Uri.parse('$baseUrl/asset/$ogID');
    var response = await http.get(url);
    print('url new: $url');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      if (mounted) {
        setState(() {
          OGnama.add(data['nama']);
          OGalamat.add(data['alamat']);
        });
      }
    } else {
      print('Response code error: ${response.statusCode}');
    }
  }

  void _searchSurvey(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProfiles = List.from(OGnama);
      });
    } else {
      final results = OGnama.where(
              (profile) => profile.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        filteredProfiles = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surveys',
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
              padding: EdgeInsets.all(8),
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
                        onChanged: _searchSurvey,
                        decoration: const InputDecoration(
                          hintText: 'Search Survey',
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
                itemCount: filteredProfiles.length,
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
                          filteredProfiles[index],
                          style: TextStyle(
                            color: Color.fromARGB(255, 24, 41, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle:
                            Text('View assets for ${filteredProfiles[index]}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailSurveys(
                                assetId: OGid[index],
                                assetName: filteredProfiles[index],
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
