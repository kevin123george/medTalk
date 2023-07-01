import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:medTalk/components.dart';
import 'package:medTalk/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../models/records.dart';
import '../providers/font_provider.dart';
import '../util/db_helper.dart';

const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  var editDoctorNameLabel;
  var editRecordTitleLabel;
  var dictionaryTitle;
  var author;
  var saveLabel;

  List<Records> records = [];
  var jsonData;
  DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  late PickerDateRange selectedDateRange;
  DateTime? startDate;
  DateTime? endDate;
  bool toggle = false;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    //createDummyRecords();
    fetchRecords();
    readJsonData();
  }

  Future<void> createDummyRecords() async {
    try {
      DateTime time = DateTime(2023, 6, 16, 12, 30, 0);
      int timestampInMilliseconds = time.millisecondsSinceEpoch;
      await DatabaseHelper.addRecord(
        new Records(
          text: "Hallo, Ich heiße Dr. John Doe.",
          timestamp: timestampInMilliseconds,
        ),
      );
      time = DateTime(2023, 5, 31, 12, 30, 0);
      timestampInMilliseconds = time.millisecondsSinceEpoch;
      await DatabaseHelper.addRecord(
        new Records(
          text: "Hallo, Ich heiße Dr. Jane Doe.",
          timestamp: timestampInMilliseconds,
        ),
      );
    } catch (e) {
      print("An error occurred while creating dummy records: $e");
    }
  }

  void _onSearch(String q) {
    setState(() {
      searchQuery = q;
    });
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    print("sdsdsdsdsd");
    print(startDate);
    if (startDate != null && endDate != null) {
      print("inside if");
      DateTime endDateRounded = roundEndDate(endDate!);
      final List<Records> fetchedRecords =
          await DatabaseHelper.fetchAllRecordsInTimeRange(
              startDate!, endDateRounded);
      setState(() {
        records = fetchedRecords;
      });
    } else {
      final List<Records> fetchedRecords =
          await DatabaseHelper.fetchAllRecords();
      setState(() {
        records = fetchedRecords;
      });
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final List<Records> fetchedRecords =
          await DatabaseHelper.searchRecords(searchQuery!);
      setState(() {
        records = fetchedRecords;
      });
    } else if(!(searchQuery != null && searchQuery!.isNotEmpty) && !(startDate != null && endDate != null)) {

      final List<Records> fetchedRecords =
          await DatabaseHelper.fetchAllRecords();
      setState(() {
        records = fetchedRecords;
      });
    }
  }

  Future<void> readJsonData() async {
    String jsonString = await rootBundle
        .loadString('assets/combined_medical_data_dict_lower.json');
    setState(() {
      jsonData = json.decode(jsonString);
    });
    print(jsonData);
  }

  String medDictLookUp(String userInput) {
    RegExp wordPattern = RegExp(r'\b\w+\b');
    List<String?> preprocessedWords = wordPattern.allMatches(userInput.toLowerCase()).map((match) => match.group(0)).toList();
    List<String> combinations = [];

    for (int i = 0; i < preprocessedWords.length; i++) {
      for (int j = i + 1; j < preprocessedWords.length + 1; j++) {
        String phrase = preprocessedWords.sublist(i, j).join(' ');
        combinations.add(phrase);
      }
    }

    String output = '';

    for (String phrase in combinations) {
      if (jsonData.containsKey(phrase.toLowerCase())) {
        String definition = jsonData[phrase.toLowerCase()]["Definition"];
        output += '$phrase: $definition\n';
      }
    }

    return output;
  }

  DateTime roundEndDate(DateTime originalDateTime) {
    DateTime newDateTime = DateTime(originalDateTime.year,
        originalDateTime.month, originalDateTime.day, 23, 59, 59);
    return newDateTime;
  }

  String getFormattedTimestamp(int timestampInMilliseconds) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value != null &&
        args.value.startDate != null &&
        args.value.endDate != null) {
      setState(() {
        selectedDateRange = args.value!;
        startDate = selectedDateRange.startDate;
        endDate = selectedDateRange.endDate;
      });
    } else {
      setState(() {
        startDate = null;
        endDate = null;
      });
    }
  }

  void _onClear() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    fetchRecords();
  }

  Future<void> confirmDeleteRecord(Records record) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              const SizedBox(width: 10),
              const Text('Löschung bestätigen'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Sind Sie sicher, dass Sie den Eintrag vom ${getFormattedTimestamp(record.timestamp)} '
                  'löschen möchten?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () async {
                await DatabaseHelper.deleteRecord(record);
                setState(() {
                  fetchRecords();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> editRecord(Records record) async {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double modalHeight = screenHeight * 0.75;
    TextEditingController titleController =
        TextEditingController(text: record.title);
    TextEditingController nameController =
        TextEditingController(text: record.name);
    TextEditingController textController =
        TextEditingController(text: record.text);
    final language = context.read<LanguageProvider>().languageMap;
    editDoctorNameLabel = language['edit_docname']!;
    editRecordTitleLabel = language['edit_recordtitle']!;
    dictionaryTitle = language['dictionary_title']!;
    author = language['author']!;
    saveLabel = language['save']!;
    // Map<String, String> language =
    //     context.watch<LanguageProvider>().languageMap;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: modalHeight,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    getFormattedTimestamp(record.timestamp),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    // labelText: language['edit_docname'],
                    labelText: editRecordTitleLabel,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: editDoctorNameLabel,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: textController,
                    onChanged: (value) {
                      record.text = value;
                    },
                    maxLines: null, // or omit maxLines property
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () async {
                      record.title = titleController.text;
                      record.name = nameController.text;
                      await DatabaseHelper.updateRecord(record);
                      Navigator.pop(context);
                      fetchRecords();
                    },
                    child: Text(saveLabel)),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      // Refresh the record list after closing the modal
      fetchRecords();
    });
  }

  Future<void> openRecordDetailsModal(Records record, double fontSize) async {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double modalHeight = screenHeight * 0.5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              // height: modalHeight,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      title: Text(
                        getFormattedTimestamp(record.timestamp),
                      ),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Handle edit button press
                            editRecord(record);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            var data = confirmDeleteRecord(record);
                            int idValue = record.id!;
                            await Future.delayed(
                                const Duration(seconds: 1), () {});
                            Records? value =
                                await DatabaseHelper.fetchRecordById(idValue);
                            if (value == null) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ])),
                  ListTile(
                    title: Text(
                      record.title?.isEmpty ?? true ? '' : record.title!,
                      style: TextStyle(
                        fontSize: fontSize ,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),

                  SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text(
                          record.name?.isEmpty ?? true ? '' : record.name!,
                          style: TextStyle(
                            fontSize: fontSize ,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),

                        Text(
                          record.text,
                          style: TextStyle(fontSize: fontSize),
                        ),
                        Divider(height:fontSize,color: Colors.cyan,),
                        Text(
                          dictionaryTitle,
                          style: TextStyle(fontSize: fontSize),
                        ),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: fontSize * 0.9),
                            children: <TextSpan>[
                              TextSpan(
                                text: medDictLookUp(record.text),
                                style: TextStyle(
                                  fontSize: fontSize * 0.7,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      // Refresh the record list after closing the modal
      fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<LanguageProvider>().languageMap;
    editDoctorNameLabel = language['edit_docname']!;
    editRecordTitleLabel = language['edit_recordtitle']!;
    dictionaryTitle = language['dictionary_title']!;
    author = language['author']!;

    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    double fontSize = context.watch<FontProvider>().font_size;
    // Map<String, String> language =
    //     context.watch<LanguageProvider>().languageMap;

    if (fontSize == 0.0) {
      fontSize = 16;
    } else if (fontSize == 1.0) {
      fontSize = 24;
    } else if (fontSize == 2.0) {
      fontSize = 30;
    }
    return Expanded(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchBar(
                        leading: Icon(Icons.search),
                        hintText: language['search'],

                        // controller: searchController,
                        onChanged: (value) async {
                          if (value.length >= 3) {
                            _onSearch(value);
                          } else {
                            final List<Records> fetchedRecords =
                                await DatabaseHelper.fetchAllRecords();
                            setState(() {
                              records = fetchedRecords;
                            });
                          }
                        }), // mainAxisAlignment: MainAxisAlignment.end
                  ),
                  SizedBox(width: 8.0),
                  Tooltip(
                    message: 'Filter',
                    child: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          SfDateRangePicker(
                                            controller:
                                                _dateRangePickerController,
                                            showTodayButton: true,
                                            showActionButtons: true,
                                            onSubmit: (Object? val) {
                                              fetchRecords();
                                              Navigator.pop(context);
                                            },
                                            onCancel: () {
                                              _onClear();
                                              _dateRangePickerController
                                                  .selectedRange = null;
                                              Navigator.pop(context);
                                            },
                                            selectionMode:
                                                DateRangePickerSelectionMode
                                                    .range,
                                            onSelectionChanged:
                                                _onSelectionChanged,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              divider,
              Expanded(
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return InkWell(
                      onTap: () {
                        openRecordDetailsModal(record, fontSize);
                      },
                      child: Card(
                        child: ListTile(
                          title: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              record.title?.isEmpty ?? true
                                  ? ' '
                                  : record.title!,
                              style: TextStyle(
                                  fontSize: fontSize, fontWeight: FontWeight.bold),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Handle edit button press
                                  editRecord(record);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final deletedRows =
                                      await DatabaseHelper.deleteRecord(record);
                                  if (deletedRows > 0) {
                                    setState(() {
                                      records.remove(record);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    author + ": ",
                                    style: TextStyle(
                                      fontSize: fontSize / 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    record.name?.isEmpty ?? true
                                        ? ''
                                        : record.name!,
                                    style: TextStyle(
                                      fontSize: fontSize / 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  getFormattedTimestamp(record.timestamp),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      record.text,
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
