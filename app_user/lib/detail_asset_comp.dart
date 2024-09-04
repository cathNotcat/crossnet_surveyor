// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:app_user/verification.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailAssetComp extends StatefulWidget {
  final assetID;
  final assetName;
  final location;
  final type;
  final area;
  final value;
  final condition;
  final coordinate;
  final verification_status;
  const DetailAssetComp(
      {super.key,
      this.assetName,
      this.location,
      this.type,
      this.verification_status,
      this.area,
      this.value,
      this.condition,
      this.assetID,
      this.coordinate});

  @override
  State<DetailAssetComp> createState() => _DetailAssetCompState();
}

class _DetailAssetCompState extends State<DetailAssetComp> {
  final List<String> tags = [
    'Cafe',
    'Restaurant',
  ];

  LatLng googleCoordinate = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    if (widget.coordinate != null) {
      List<String> parts = widget.coordinate!.split(', ');

      double latitude = double.parse(parts[1]);
      double longitude = double.parse(parts[0]);

      googleCoordinate = LatLng(latitude, longitude);
      print('coordinate: ${googleCoordinate.toString()}');
    } else {
      googleCoordinate = LatLng(0, 0);
    }
  }

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
          '${widget.assetName}',
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
                    formFieldTemplate(
                        textTitle: 'Asset ID',
                        textLabel: widget.assetID.toString()),
                    formFieldTemplate(
                        textTitle: 'Location',
                        textLabel: widget.location.toString()),
                    formFieldTemplate(
                        textTitle: 'Type', textLabel: widget.type.toString()),
                    // formFieldTemplate(
                    //   textTitle: 'Usage',
                    //
                    //   textLabel: widget.usage.toString(),
                    // ),
                    formFieldTemplate(
                        textTitle: 'Area', textLabel: widget.area.toString()),
                    formFieldTemplate(
                        textTitle: 'Value', textLabel: widget.value.toString()),
                    Text('Condition', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    TextFormField(
                      enabled: false,
                      minLines: 3,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.white,
                        labelText: widget.condition,
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
                      textAlignVertical: TextAlignVertical.top,
                    ),
                    SizedBox(height: 8),
                    formFieldTemplate(
                        textTitle: 'Coordinate',
                        textLabel: widget.coordinate.toString()),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: googleCoordinate, zoom: 13),
                        markers: {
                          Marker(
                            markerId: MarkerId('sourceLocation'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: googleCoordinate,
                          ),
                        },
                      ),
                    ),
                    formFieldTemplate(
                      textTitle: 'Verification Status',
                      textLabel: widget.verification_status.toString(),
                      isStyle: true,
                    ),
                    SizedBox(height: 16),
                    Container(
                      // padding: EdgeInsets.all(16),
                      color: Color.fromARGB(255, 242, 243, 247),
                      width: double.infinity,
                      height: 56,
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SendProposal()));
                        },
                        child: const Text(
                          'RENT',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}

Widget formFieldTemplate({
  required String textTitle,
  required String textLabel,
  bool isStyle = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8),
      Text(textTitle, style: TextStyle(fontSize: 18)),
      SizedBox(height: 8),
      TextFormField(
        enabled: false,
        cursorColor: const Color.fromARGB(500, 24, 41, 78),
        style: TextStyle(
          color: Color.fromARGB(500, 24, 41, 78),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: textLabel,
          labelStyle: TextStyle(
            color: isStyle ? Colors.green : Color.fromARGB(500, 24, 41, 78),
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

class SendProposal extends StatefulWidget {
  const SendProposal({super.key});

  @override
  State<SendProposal> createState() => _SendProposalState();
}

class _SendProposalState extends State<SendProposal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Form(
          child: Column(
            children: [
              Container(
                height: 56,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      // foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upload Proposal',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(480, 24, 41, 78),
                              fontWeight: FontWeight.normal),
                        ),
                        Icon(
                          Icons.file_upload_outlined,
                          color: Color.fromARGB(500, 24, 41, 78),
                        ),
                      ],
                    )),
              ),
              SizedBox(height: 16),
              TextFormField(
                minLines: 8,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Description',
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
                textAlignVertical: TextAlignVertical.bottom,
              ),
              SizedBox(height: 32),
              Container(
                // padding: EdgeInsets.all(16),
                color: Color.fromARGB(255, 242, 243, 247),
                width: double.infinity,
                height: 56,
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HasBeenSent(
                              title: 'REQUEST HAS BEEN SENT',
                              detail:
                                  'Your request to buy this asset has been sent. \nPlease wait for the meeting schedule to do the transaction.',
                            )));
                  },
                  child: const Text(
                    'SEND',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

class SearchAssets extends StatefulWidget {
  const SearchAssets({super.key});

  @override
  State<SearchAssets> createState() => _SearchAssetsState();
}

class _SearchAssetsState extends State<SearchAssets> {
  List<String> filteredAsset = [];

  List<int> assetID = [];
  List<String> assetNames = [];
  List<String> assetAlamat = [];
  List<String> assetTipe = [];
  List<int> assetArea = [];
  List<int> assetValue = [];
  List<String> assetCondition = [];
  List<String> assetVerif = [];

  final List<String> _filterOptions = ['Option 1', 'Option 2', 'Option 3'];
  final Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    // filteredAsset = List.from(companyProfiles);
    _fetchAssets();
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
            assetID.add(asset['id_asset']);
            assetAlamat.add(asset['alamat']);
            assetTipe.add(asset['tipe']);
            assetArea.add(asset['luas']);
            assetValue.add(asset['nilai']);
            assetCondition.add(asset['kondisi']);
            assetVerif.add(asset['status_verifikasi']);
            setState(() {
              assetNames = assetNames;
              assetID = assetID;
              assetAlamat = assetAlamat;
              assetTipe = assetTipe;
              assetArea = assetArea;
              assetValue = assetValue;
              assetCondition = assetCondition;
              assetVerif = assetVerif;
              filteredAsset = List.from(assetNames);
            });
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

  void _searchAsset(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredAsset = List.from(assetNames);
      });
    } else {
      final results = assetNames
          .where(
              (profile) => profile.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        filteredAsset = results;
      });
    }
  }

  void _showFilterDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Filters'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _filterOptions.map((String option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: _selectedFilters.contains(option),
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedFilters.add(option);
                      } else {
                        _selectedFilters.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedFilters() {
    return Wrap(
      spacing: 8.0,
      children: _selectedFilters.map((filter) {
        return Chip(
          label: Text(filter),
          onDeleted: () {
            setState(() {
              _selectedFilters.remove(filter);
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assets',
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
                        onChanged: _searchAsset,
                        decoration: const InputDecoration(
                          hintText: 'Search Asset',
                          hintStyle: TextStyle(fontSize: 16.0),
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        if (_selectedFilters.contains(value)) {
                          _selectedFilters.remove(value);
                        } else {
                          _selectedFilters.add(value);
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return _filterOptions.map((String option) {
                        return PopupMenuItem<String>(
                          value: option,
                          child: Row(
                            children: [
                              Checkbox(
                                value: _selectedFilters.contains(option),
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedFilters.add(option);
                                    } else {
                                      _selectedFilters.remove(option);
                                    }
                                  });
                                },
                              ),
                              Text(option),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list),
                          SizedBox(width: 8),
                          Text('Filter'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            assetNames.isEmpty
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredAsset.length,
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
                                filteredAsset[index],
                                style: TextStyle(
                                  color: Color.fromARGB(255, 24, 41, 78),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(assetAlamat[index]),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailAssetComp(
                                      assetID: assetID[index],
                                      assetName: assetNames[index],
                                      location: assetAlamat[index],
                                      type: assetTipe[index],
                                      area: assetArea[index],
                                      value: assetValue[index],
                                      condition: assetCondition[index],
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
          ],
        ),
      ),
    );
  }
}
