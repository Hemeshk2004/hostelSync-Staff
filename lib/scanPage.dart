import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isProcessing = false;
  String? scannedRollNo;

  @override
  void initState() {
    super.initState();
    _initializeAttendance();
  }

  Future<void> _initializeAttendance() async {
    final dateToday = DateTime.now();
    final formattedDate = "${dateToday.year}${dateToday.month}${dateToday.day}";
    final attendanceCollectionName = "Attendance$formattedDate";

    try {
      // Fetch all students from the "attendancecollection" collection
      final studentsSnapshot =
          await _firestore.collection("attendancecollection").get();

      // Mark all students as Absent in the attendance collection
      for (var student in studentsSnapshot.docs) {
        await _firestore
            .collection(attendanceCollectionName)
            .doc(student['rollNo'])
            .set({
          'name': student['name'],
          'rollNo': student['rollNo'],
          'attendance': 'Absent',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error initializing attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan For Attendance"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MobileScanner(
                  onDetect: (BarcodeCapture barcodeCapture) {
                    final List<Barcode> barcodes = barcodeCapture.barcodes;
                    if (!isProcessing && barcodes.isNotEmpty) {
                      setState(() {
                        isProcessing = true;
                        scannedRollNo = barcodes.first.rawValue;
                      });

                      if (scannedRollNo != null) {
                        setState(() {
                          isProcessing = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (scannedRollNo != null)
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Text(
                    "Scanned Roll No: $scannedRollNo",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (scannedRollNo != null) {
                      await _markAsPresent(scannedRollNo!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Marked $scannedRollNo as Present if found")),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scannedRollNo = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 68, 224, 224)),
                  child: const Text("Reset"),
                ),
              ],
            ),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _markAsPresent(String rollNo) async {
    final dateToday = DateTime.now();
    final formattedDate = "${dateToday.year}${dateToday.month}${dateToday.day}";
    final attendanceCollectionName = "Attendance$formattedDate";

    try {
      // Check if the roll number exists in the "attendancecollection" collection
      final attendancecollectionSnapshot = await _firestore
          .collection("attendancecollection")
          .where("rollNo", isEqualTo: rollNo)
          .get();

      if (attendancecollectionSnapshot.docs.isNotEmpty) {
        final studentData = attendancecollectionSnapshot.docs.first;
        final studentName = studentData['name'];

        // Mark the student as Present in the attendance collection
        await _firestore
            .collection(attendanceCollectionName)
            .doc(rollNo)
            .set({
          'name': studentName,
          'rollNo': rollNo,
          'attendance': 'Present',
        }, SetOptions(merge: true));
      } else {
        debugPrint("Roll number $rollNo not found in the student collection.");
      }
    } catch (e) {
      debugPrint("Error marking roll number as present: $e");
    }
  }
}
