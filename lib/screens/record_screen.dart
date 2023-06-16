import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  DateTime endDate = DateTime.now();
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));

  @override
  void initState() {
    super.initState();
    //createDummyRecords();
    fetchRecords();
  }

  Future<void> createDummyRecords() async {
    try {
      DateTime time = DateTime(2023, 5, 31, 12, 30, 0);
      int timestampInMilliseconds = time.millisecondsSinceEpoch;
      await DatabaseHelper.addRecord(
        new Records(
          text: "Hallo, Ich heiße Dr. John Doe.",
          timestamp: timestampInMilliseconds,
        ),
      );
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
    final List<Records> fetchedRecords = await DatabaseHelper.fetchAllRecords();
    setState(() {
      records = fetchedRecords;
    });
  }

  String getFormattedTimestamp(int timestampInMilliseconds) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInMilliseconds);
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }

  Future<void> confirmDeleteRecord(Records record) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  'Sind Sie sicher, dass Sie den Eintrag vom ${getFormattedTimestamp(record.timestamp)} löschen möchten?',
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
                final deletedRows = await DatabaseHelper.deleteRecord(record);
                if (deletedRows > 0) {
                  setState(() {
                    records.remove(record); // Remove the deleted record from the list
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(displayColor: Theme.of(context).colorScheme.onSurface);
    return Expanded(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ListTile(
                  title: Text(
                    getFormattedTimestamp(record.timestamp),
                    style:TextStyle(fontSize: 20),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      confirmDeleteRecord(record);
                    },
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      record.text,
                      style:TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
