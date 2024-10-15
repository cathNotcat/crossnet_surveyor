// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class DetailSurveys extends StatefulWidget {
  final int transId;
  final int assetId;

  const DetailSurveys(
      {super.key, required this.assetId, required this.transId});

  @override
  State<DetailSurveys> createState() => _DetailSurveysState();
}

class _DetailSurveysState extends State<DetailSurveys> {
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  int id = 0;
  String nama = '';
  String location = '';
  String type = '';
  String area = '';
  int value = 0;
  String condition = '';
  String coordinate = '';
  String coordinateBoundary = '';
  List<dynamic> tagsList = [];
  List<String> tags = [];
  List<dynamic> usageList = [];
  List<String> usage = [];

  List<String> tagItems = [];
  List<bool> tagIsChecked = [];
  List<int> tagSelectedId = [];
  List<String> tagSelectedItems = [];
  int get checkedCount => tagIsChecked.where((isChecked) => isChecked).length;

  List<String> usageItems = [];
  List<bool> usageIsChecked = [];
  List<int> usageSelectedId = [];
  List<String> usageSelectedItems = [];
  int get checkedCountU =>
      usageIsChecked.where((isChecked) => isChecked).length;

  bool isLoading = true;
  bool submitted = false;

  late TextEditingController _idController;
  late TextEditingController _namaController;
  late TextEditingController _locationController;
  late TextEditingController _typeController;
  late TextEditingController _usageController;
  late TextEditingController _areaController;
  late TextEditingController _valueController;
  late TextEditingController _conditionController;
  late TextEditingController _coordinateController;
  late TextEditingController _coordinateBoundaryController;
  late TextEditingController _tagsController;

  Image? profilePic;
  List<PlatformFile> selectedPhotos = [];

  LatLng coordinateP = LatLng(0, 0);
  LatLng coordinateBound = LatLng(0, 0);
  @override
  void initState() {
    super.initState();
    print('in details: ${widget.assetId}');
    _loadAsset();
    _getAllTags();
    _getAllUsage();
    _idController = TextEditingController();
    _namaController = TextEditingController();
    _locationController = TextEditingController();
    _typeController = TextEditingController();
    _usageController = TextEditingController();
    _areaController = TextEditingController();
    _valueController = TextEditingController();
    _conditionController = TextEditingController();
    _coordinateController = TextEditingController();
    _coordinateBoundaryController = TextEditingController();
    _tagsController = TextEditingController();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> newFiles = result.files.where((file) {
        return !selectedPhotos!.any((selectedFile) =>
            selectedFile.name == file.name && selectedFile.path == file.path);
      }).toList();

      if (newFiles.isNotEmpty) {
        setState(() {
          selectedPhotos!.addAll(newFiles);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No new files selected!'),
        ));
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      selectedPhotos!.removeAt(index);
    });
  }

  Future<void> _loadAsset() async {
    setState(() {
      isLoading = true;
    });
    print('transid: ${widget.transId}');

    var url = Uri.parse('$baseUrl/survey_req/${widget.transId}');

    print('url load asset: $url');
    var response = await http.get(url);

    print('response code load asset: ${response.statusCode}');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];

      if (data['status_submit'] == "Y") {
        setState(() {
          submitted = true;
        });
      }

      if (data['tags_new'] != "" || data['tags_new'] != null) {
        tagsList = data['tags_new'];
      } else {
        tagsList = data['tags_old'];
      }

      if (data['usage_new'] != "" || data['usage_new'] != null) {
        usageList = data['usage_new'];
      } else {
        usageList = data['usage_old'];
      }

      print('usagelist: $usageList');

      if (data['luas_new'] != "" || data['luas_new'] != null) {
        area = data['luas_new'];
      } else {
        area = data['luas_old'];
      }

      if (data['nilai_new'] != "" || data['nilai_new'] != null) {
        value = data['nilai_new'];
      } else {
        value = data['nilai_old'];
      }

      if (data['kondisi_new'] != "" || data['kondisi_new'] != null) {
        condition = data['kondisi_new'];
      } else {
        condition = data['kondisi_old'];
      }

      if (data['titik_koordinat_new'] != "" ||
          data['titik_koordinat_new'] != null) {
        coordinate = data['titik_koordinat_new'];
        print('coordinate load asset: $coordinate');
        print('coordinateP load asset: $coordinateP');
      } else {
        coordinate = data['titik_koordinat_old'];
      }

      if (data['batas_koordinat_new'] != "" ||
          data['batas_koordinat_new'] != null) {
        coordinateBoundary = data['batas_koordinat_new'];
      } else {
        coordinateBound = data['batas_koordinat_old'];
      }

      setState(() {
        for (var tagsItem in tagsList) {
          String tagName = tagsItem['nama'];
          int index = tagItems.indexOf(tagName);
          print('indexx: $index');
          if (index != -1) {
            tagIsChecked[index] = true;
          }
        }
        print('checkedd: $tagIsChecked');

        for (var usagesItem in usageList) {
          String usageName = usagesItem['nama'];
          int index = usageItems.indexOf(usageName);
          print('indexxU: $index');
          if (index != -1) {
            usageIsChecked[index] = true;
          }
        }
        print('checkeddUUU: $usageIsChecked');
      });

      setState(() {
        id = data['id_asset'];
        nama = data['nama_aset'];
        location = data['lokasi_asset'];
        type = data['tipe_asset'];
        _idController.text = id.toString();
        _namaController.text = nama;
        _locationController.text = location;
        if (type == 'B') {
          _typeController.text = 'Building';
        }
        if (type == 'A') {
          _typeController.text = 'Apartement';
        }
        if (type == 'L') {
          _typeController.text = 'Land';
        }
        _areaController.text = area.toString();
        _valueController.text = value.toString();
        _conditionController.text = condition;
        _coordinateController.text = coordinate.toString();
        _coordinateBoundaryController.text = coordinateBoundary.toString();
        for (var tagsItem in tagsList) {
          tags.add(tagsItem['nama']);
        }
        for (var usageItem in usageList) {
          usage.add(usageItem['nama']);
        }
        isLoading = false;
      });

      if (coordinate != null) {
        print('Original coordinatep string: $coordinate');

        List<String> parts = coordinate!.split(', ');

        if (parts.length == 2) {
          try {
            double latitude = double.parse(parts[0]);
            double longitude = double.parse(parts[1]);

            setState(() {
              coordinateP = LatLng(latitude, longitude);
            });
            print('coordinateP after api: ${coordinateP.toString()}');
          } catch (e) {
            print('Error parsing coordinate: $e');
          }
        } else {
          print(
              'Error: coordinate string does not contain both latitude and longitude.');
        }
      } else {
        print('Error: coordinate is null.');
      }
      if (coordinateBoundary != null) {
        List<String> parts = coordinateBoundary!.split(', ');
        if (parts.length == 2) {
          try {
            double latitude = double.parse(parts[0]);
            double longitude = double.parse(parts[1]);

            coordinateBound = LatLng(latitude, longitude);
            print('coordinate: ${coordinateBound.toString()}');
          } catch (e) {
            print('Error parsing coordinate: $e');
          }
        } else {
          print('Error: coordinate is null.');
        }
      } else {
        print('Response error: ${response.statusCode}');
      }
    }
  }

  // void _updateData(int transid) async {
  //   print('trnas id update: $transid');
  //   String url = '$baseUrl/survey_req/submit';
  //   String tagsIds = tagSelectedId.join(',');
  //   String usageIds = usageSelectedId.join(',');
  //   print('tagsId: $tagsIds');
  //   print('usageId: $usageIds');
  //   Map<String, dynamic> updatedData = {
  //     'id': id,
  //     'usage': usageIds,
  //     'luas': _areaController.text,
  //     'nilai': _valueController.text,
  //     'kondisi': _conditionController.text,
  //     'titik_koordinat': _coordinateController.text,
  //     'batas_koordinat': _coordinateBoundaryController.text,
  //     'tags': tagsIds,
  //   };
  //   print('updatedData: $updatedData');
  //   var response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(updatedData),
  //   );
  //   if (response.statusCode == 200) {
  //     var responseBody = jsonDecode(response.body);
  //     print('resposne: $responseBody');
  //     print('Data updated successfully');
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => SubmitSurvey(),
  //       ),
  //     );
  //     print('message: ${responseBody['message']}');
  //   } else {
  //     print('Failed to update data');
  //   }
  // }

  Future<void> uploadPost(
    int id,
  ) async {
    var url = Uri.parse('$baseUrl/survey_req/submit');
    // var url = Uri.parse('$baseUrl/survey_req/submit/files');

    var request = http.MultipartRequest('POST', url);

    String tagsIds = tagSelectedId.join(',');
    String usageIds = usageSelectedId.join(',');

    String stringid = id.toString();

    request.fields['id'] = stringid;
    request.fields['usage'] = usageIds;
    request.fields['luas'] = _areaController.text;
    request.fields['nilai'] = _valueController.text;
    request.fields['kondisi'] = _conditionController.text;
    request.fields['titik_koordinat'] = _coordinateController.text;
    request.fields['batas_koordinat'] = _coordinateBoundaryController.text;
    request.fields['tags'] = tagsIds;

    // for (PlatformFile file in selectedPhotos) {
    //   request.files.add(
    //     await http.MultipartFile.fromPath(
    //       'GambarFile',
    //       file.path!,
    //       filename: file.name,
    //     ),
    //   );
    //   print('the photo: ${file}');
    // }

    print('waiting submit');
    print('file: ${selectedPhotos.length}');

    var response = await request.send();

    print('response submit: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print('Post successful: $responseBody');

      goToPage(SubmitSurvey());
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Failed to post: ${response.statusCode} - $responseBody');
    }
  }

  Future<void> _getAllTags() async {
    var url = Uri.parse('$baseUrl/tags');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var tags = data['data'] as List?;

        if (tags != null && tags.isNotEmpty) {
          for (var tag in tags) {
            setState(() {
              tagItems.add(tag['nama'] ?? '');
              tagIsChecked.add(false);
            });
          }
        } else {
          print('No tags found');
        }
      } else {
        print('Failed to load tags. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tags: $error');
    }
  }

  void _tagsCheckbox() async {
    List<bool> localChecked = List.from(tagIsChecked);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 242, 243, 247),
              title: Text('Tag ($checkedCount)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tagItems.length, (index) {
                    return CheckboxListTile(
                      title: Text(tagItems[index]),
                      value: localChecked[index],
                      onChanged: (value) {
                        setState(() {
                          localChecked[index] = value!;
                          tagIsChecked[index] = value!;
                          print('Number of checked tags: $checkedCount');
                        });
                        print('tag is checked: $tagIsChecked');
                      },
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      tagIsChecked = List.from(localChecked);
                      tagSelectedItems.clear();
                      for (int i = 0; i < tagItems.length; i++) {
                        if (tagIsChecked[i]) {
                          tagSelectedItems.add(tagItems[i]);
                        }
                      }
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
    tagSelectedId.clear();
    for (int i = 0; i < tagItems.length; i++) {
      if (tagIsChecked[i] == true) {
        tagSelectedId.add(i + 1);
      }
    }
    print('tag selected id: $tagSelectedId');
  }

  Future<void> _getAllUsage() async {
    var url = Uri.parse('$baseUrl/usage');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        var usages = data['data'] as List;
        if (usages.isNotEmpty) {
          for (var usage in usages) {
            setState(() {
              usageItems.add(usage['nama']);
              usageIsChecked.add(false);
            });
          }
        } else {
          print('No tags found');
        }
      } else {
        print('Failed to load tags. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching assets: $error');
    }
  }

  void _usageCheckbox() async {
    List<bool> localChecked = List.from(usageIsChecked);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 242, 243, 247),
              title: Text('Usage ($checkedCountU)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(usageItems.length, (index) {
                    return CheckboxListTile(
                      title: Text(usageItems[index]),
                      value: localChecked[index],
                      onChanged: (value) {
                        setState(() {
                          localChecked[index] = value!;
                          usageIsChecked[index] = value!;
                          print('Number of checked usages: $checkedCount');
                        });
                        print('usage is checked: $usageIsChecked');
                      },
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      usageIsChecked = List.from(localChecked);
                      usageSelectedItems.clear();
                      for (int i = 0; i < usageItems.length; i++) {
                        if (usageIsChecked[i]) {
                          usageSelectedItems.add(tagItems[i]);
                        }
                      }
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    usageSelectedId.clear();
    for (int i = 0; i < usageItems.length; i++) {
      if (usageIsChecked[i] == true) {
        usageSelectedId.add(i + 1);
      }
    }
    print('usage selected id: $usageSelectedId');
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
      appBar: AppBar(
        title: Text(
          'Surveys for $nama',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 242, 243, 247),
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _pickFiles();
                                  },
                                  child: DottedBorder(
                                    color:
                                        const Color.fromARGB(255, 24, 41, 78),
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
                                            color:
                                                Color.fromARGB(255, 24, 41, 78),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Add Photos',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 24, 41, 78),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Display selected images
                                ...?selectedPhotos
                                    ?.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  PlatformFile file = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 150,
                                          child: Image.file(
                                            File(file.path!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outlined,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            onPressed: () => _removeFile(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          formFieldTemplate(
                              enable: false,
                              textTitle: 'Asset ID',
                              textController: _idController),
                          formFieldTemplate(
                              enable: false,
                              textTitle: 'Location',
                              textController: _locationController),
                          formFieldTemplate(
                            enable: false,
                            textTitle: 'Type',
                            textController: _typeController,
                          ),
                          formFieldTemplate(
                              textTitle: 'Area',
                              textController: _areaController),
                          formFieldTemplate(
                              textTitle: 'Value',
                              textController: _valueController),
                          Text('Condition', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _conditionController,
                            minLines: 3,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(16),
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
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                          SizedBox(height: 8),
                          formFieldTemplate(
                              textTitle: 'Coordinate (Long, Lat)',
                              textController: _coordinateController),
                          SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: GoogleMap(
                              initialCameraPosition:
                                  CameraPosition(target: coordinateP, zoom: 13),
                              markers: {
                                Marker(
                                  markerId: MarkerId('sourceLocation'),
                                  icon: BitmapDescriptor.defaultMarker,
                                  position: coordinateP,
                                ),
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Coordinate Boundary (enter to add more)',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _coordinateBoundaryController,
                            minLines: 3,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(16),
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
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                          SizedBox(height: 8),
                          Text('Tags', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: _tagsCheckbox,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color: Color.fromARGB(500, 24, 41, 78),
                                ),
                              ),
                              height: 48,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Choose tags',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(500, 24, 41, 78),
                                      )),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Usage', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: _usageCheckbox,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color: Color.fromARGB(500, 24, 41, 78),
                                ),
                              ),
                              height: 48,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Choose usage',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(500, 24, 41, 78),
                                      )),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    submitted == false
                        ? Container(
                            padding: const EdgeInsets.only(top: 40),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
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
                                onPressed: () {
                                  uploadPost(widget.transId);
                                },
                                child: const Text(
                                  'SUBMIT',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(top: 40),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 177, 179, 184),
                                  foregroundColor:
                                      Color.fromARGB(255, 241, 241, 241),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: () {
                                  // uploadPost(widget.transId);
                                },
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

Widget formFieldTemplate({
  required String textTitle,
  required TextEditingController textController,
  bool enable = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8),
      Text(textTitle, style: TextStyle(fontSize: 18)),
      SizedBox(height: 8),
      TextFormField(
        enabled: enable,
        controller: textController,
        cursorColor: const Color.fromARGB(500, 24, 41, 78),
        style: const TextStyle(color: Color.fromARGB(500, 24, 41, 78)),
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
  );
}

class SubmitSurvey extends StatefulWidget {
  const SubmitSurvey({super.key});

  @override
  State<SubmitSurvey> createState() => _SubmitSurveyState();
}

class _SubmitSurveyState extends State<SubmitSurvey> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 160,
              color: Color.fromARGB(500, 24, 41, 78),
            ),
            SizedBox(height: 32),
            Text(
              'SUBMISSION SUCCESSFUL',
              style: TextStyle(
                  color: Color.fromARGB(500, 24, 41, 78),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'The survey data has been submitted, wait for the verification process.',
              style: TextStyle(
                color: Color.fromARGB(500, 24, 41, 78),
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              color: Color.fromARGB(255, 242, 243, 247),
              width: double.infinity,
              height: 80,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color.fromARGB(500, 24, 41, 78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'BACK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(500, 24, 41, 78),
                  ),
                ),
              ),
            ),
          ],
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
  String baseUrl = 'http://leap.crossnet.co.id:1762';
  String id = '';
  String name = '';
  String location = '';
  String type = '';
  String area = '';
  String value = '';
  String condition = '';
  String coordinate = '';
  String coordinateBoundary = '';
  String usage = '';
  List<String> coordinateBoundaryList = [];
  List<dynamic> tags = [];
  List<dynamic> usages = [];
  LatLng googleCoordinate = LatLng(0, 0);

  LatLng coordinateP = LatLng(0, 0);
  List<LatLng> coordinateB = [];

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    //ganti api jadi /survey_req/asset/$asset_id
    var url = Uri.parse('$baseUrl/survey_req/aset/${widget.assetId}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      var tagsData = data['tags_new'];
      var usagesData = data['usage_new'];

      if (tagsData != null) {
        for (var tag in tagsData) {
          tags.add(tag['nama']);
        }
      }

      if (usagesData != null) {
        for (var usage in usagesData) {
          usages.add(usage['nama']);
        }
      }
      print('tags: $tags');
      setState(() {
        id = widget.assetId.toString();
        name = data['nama_aset'];
        location = data['lokasi_asset'];
        type = data['tipe_asset'];
        usage = usages.join(', ').toString();
        area = data['luas_new'].toString();
        value = data['nilai_new'].toString();
        condition = data['kondisi_new'];
        coordinate = data['titik_koordinat_new'].toString();
        coordinateBoundary = data['batas_koordinat_new'].toString();
        tags = tags;
        usages = usages;
      });

      if (coordinate != null) {
        print('Original coordinatep string: $coordinate');

        List<String> parts = coordinate!.split(', ');

        if (parts.length == 2) {
          try {
            double latitude = double.parse(parts[1]);
            double longitude = double.parse(parts[0]);

            setState(() {
              coordinateP = LatLng(latitude, longitude);
            });
            print('coordinateP after api: ${coordinateP.toString()}');
          } catch (e) {
            print('Error parsing coordinate: $e');
          }
        } else {
          print(
              'Error: coordinate string does not contain both latitude and longitude.');
        }
      } else {
        print('Error: coordinate is null.');
      }

      coordinateBoundaryList = coordinateBoundary!.split('\n');
      int n = coordinateBoundaryList.length;
      if (coordinateBoundaryList.isNotEmpty) {
        for (int i = 0; i < n; i++) {
          List<String> parts = coordinateBoundaryList[i].split(',');

          if (parts.length == 2) {
            double longitude = double.parse(parts[0].trim());
            double latitude = double.parse(parts[1].trim());
            coordinateB.add(LatLng(latitude, longitude));
          }
        }
      } else {
        coordinateP = LatLng(0, 0);
      }
    } else {
      print('Response error: ${response.statusCode}');
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
              tags.isEmpty
                  ? SizedBox()
                  : Container(
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
                    formFieldHistoryTemplate(
                      textTitle: 'Asset ID',
                      textLabel: widget.assetId.toString(),
                    ),
                    formFieldHistoryTemplate(
                      textTitle: 'Location',
                      textLabel: location,
                    ),
                    formFieldHistoryTemplate(
                      textTitle: 'Type',
                      textLabel: type,
                    ),
                    formFieldHistoryTemplate(
                      textTitle: 'Usage',
                      textLabel: usage,
                    ),
                    formFieldHistoryTemplate(
                      textTitle: 'Area',
                      textLabel: area,
                    ),
                    formFieldHistoryTemplate(
                      textTitle: 'Value',
                      textLabel: value,
                    ),
                    formFieldHistoryTemplate(
                        textTitle: 'Condition', textLabel: condition),
                    formFieldHistoryTemplate(
                        textTitle: 'Coordinate',
                        textLabel: coordinate.toString()),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: coordinateP, zoom: 13),
                        markers: {
                          Marker(
                            markerId: MarkerId('sourceLocation'),
                            position: coordinateP,
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          controller.animateCamera(
                              CameraUpdate.newLatLng(coordinateP));
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Coordinate Boundaries',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Container(
                        height:
                            (280 * coordinateBoundaryList.length).toDouble(),
                        child: ListView.builder(
                            itemCount: coordinateB.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  TextFormField(
                                    enabled: false,
                                    cursorColor:
                                        const Color.fromARGB(500, 24, 41, 78),
                                    style: TextStyle(
                                      color: Color.fromARGB(500, 24, 41, 78),
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: coordinateBoundaryList[index],
                                      labelStyle: TextStyle(
                                        color: Color.fromARGB(500, 24, 41, 78),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(500, 24, 41, 78),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                          target: coordinateB[index], zoom: 13),
                                      markers: {
                                        Marker(
                                          markerId: MarkerId('sourceLocation'),
                                          position: coordinateB[index],
                                        ),
                                      },
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        controller.animateCamera(
                                            CameraUpdate.newLatLng(
                                                coordinateB[index]));
                                      },
                                    ),
                                  ),
                                ],
                              );
                            })),
                    SizedBox(height: 16),
                    formFieldHistoryTemplate(
                        textTitle: 'Verification',
                        textLabel: 'DONE',
                        isStyle: true)
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

Widget formFieldHistoryTemplate({
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
