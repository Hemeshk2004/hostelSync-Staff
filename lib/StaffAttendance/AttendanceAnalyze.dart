import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class AttendanceAnalyze extends StatefulWidget {
  @override
  _AttendanceAnalyze createState() => _AttendanceAnalyze();
}

class _AttendanceAnalyze extends State<AttendanceAnalyze> {
  double presentCount = 0;
  double absentCount = 0;
  double totalCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    String currentDate = DateFormat('yyyyMMdd').format(DateTime.now());
    String collectionName = 'Attendance$currentDate';

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    totalCount = snapshot.docs.length.toDouble();
    for (var doc in snapshot.docs) {
      if (doc['attendance'] == "Present") {
        presentCount++;
      } else {
        absentCount++;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double percentage = totalCount > 0 ? (presentCount / totalCount) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Attendance for ${DateTime.now().toLocal().toString().split(' ')[0]}'),
      ),
      body: Center(
        child: totalCount > 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Students: $totalCount',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Present: $presentCount',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Absent: $absentCount',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 15.0,
                    animation: true,
                    percent: percentage,
                    center: Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24.0),
                    ),
                    footer: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Attendance Percentage',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.green,
                    backgroundColor: const Color.fromARGB(255, 224, 224, 224),
                  ),
                ],
              )
            : Text(
                'No attendance records found.',
                style: TextStyle(fontSize: 20),
              ),
      ),
    );
  }
}
