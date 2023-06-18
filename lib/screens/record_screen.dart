// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/records.dart';
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

  List<Records> records = [];
  DateRangePickerController _dateRangePickerController = DateRangePickerController();
  late PickerDateRange selectedDateRange;
  DateTime? startDate;
  DateTime? endDate;
  bool toggle = false;

  @override
  void initState() {
    super.initState();
    //createDummyRecords();
    fetchRecords();
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

  Future<void> fetchRecords() async {
    if (startDate != null && endDate != null) {
      DateTime endDateRounded = roundEndDate(endDate!);
      final List<Records> fetchedRecords =
      await DatabaseHelper.fetchAllRecordsInTimeRange(startDate!, endDateRounded);
      setState(() {
        records = fetchedRecords;
      });
    }
    else {
      final List<Records> fetchedRecords = await DatabaseHelper.fetchAllRecords();
      setState(() {
        records = fetchedRecords;
      });
    }
  }

  DateTime roundEndDate(DateTime originalDateTime) {
    DateTime newDateTime = DateTime(
        originalDateTime.year,
        originalDateTime.month,
        originalDateTime.day,
        23, 59, 59);
    return newDateTime;
  }

  String getFormattedTimestamp(int timestampInMilliseconds) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value != null && args.value.startDate != null && args.value.endDate != null) {
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    return Expanded(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                                height: MediaQuery.of(context).size.height * 0.8,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          SfDateRangePicker(
                                            controller: _dateRangePickerController,
                                            showTodayButton: true,
                                            showActionButtons: true,
                                            onSubmit: (Object? val) {
                                              fetchRecords();
                                              Navigator.pop(context);
                                            },
                                            onCancel: () {
                                              _onClear();
                                              _dateRangePickerController.selectedRange = null;
                                              Navigator.pop(context);
                                            },
                                            selectionMode: DateRangePickerSelectionMode.range,
                                            onSelectionChanged: _onSelectionChanged,
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
                    return Card(
                      child: ListTile(
                        title: Text(
                          getFormattedTimestamp(record.timestamp),
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            final deletedRows = await DatabaseHelper.deleteRecord(record);
                            if (deletedRows > 0) {
                              setState(() {
                                records.remove(record);
                              });
                            }
                          },
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            record.text,
                            style: TextStyle(fontSize: 16),
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
