import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart'; // For storage permissions

class ExportAttendancePage extends StatefulWidget {
  @override
  _ExportAttendancePageState createState() => _ExportAttendancePageState();
}

class _ExportAttendancePageState extends State<ExportAttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _exportCSV(String date) async {
    try {
      // Request storage permission if not already granted
      if (await Permission.storage.request().isGranted) {
        QuerySnapshot snapshot =
            await _firestore.collection('Attendance$date').get();

        if (snapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No data found for the selected date.'),
          ));
          return;
        }

        List<List<dynamic>> csvData = [];
        csvData.add(['Roll No', 'Name', 'Attendance']);

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          csvData.add([doc.id, data['name'], data['attendance']]);
        }

        String csv = const ListToCsvConverter().convert(csvData);

        // Get external storage directory
        Directory? externalDir = await getExternalStorageDirectory();
        String downloadsPath =
            '${externalDir?.path?.split('Android')?.first}Download';

        // Create file in Downloads directory
        final File file = File('$downloadsPath/attendance_$date.csv');
        await file.writeAsString(csv);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('CSV file saved to Downloads!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Storage permission denied!'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error exporting CSV: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF0F8), // Set background color
      appBar: AppBar(
        title: Text('Export Attendance'),
        backgroundColor: Color(0xFFCAF0F8), // Set AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            SizedBox(height: 30), // Add space between AppBar and TextField
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter Date (yyyyMMdd)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19.0), // Increased radius
                ),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 60),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String date = _dateController.text;
                  if (date.isNotEmpty) {
                    _exportCSV(date);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please enter a valid date.'),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF03045E), // Set button color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(19.0), // Increased button radius
                  ),
                ),
                child: Text(
                  'Download CSV',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
