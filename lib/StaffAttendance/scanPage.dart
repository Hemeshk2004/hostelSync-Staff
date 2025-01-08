import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isProcessing = false;
  String? scannedRollNo;

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
                      await _markAttendance(scannedRollNo!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Marked $scannedRollNo as Present if found.")),
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
                      backgroundColor: const Color.fromARGB(255, 82, 218, 236)),
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

  Future<void> _markAttendance(String rollNo) async {
    final dateToday = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(dateToday);
    final attendanceCollectionName = "Attendance$formattedDate";

    try {
      // Fetch email and name from the attendancecollection
      final attendanceSnapshot = await _firestore
          .collection(
              "attendancecollection") // Replace with your collection name
          .where("rollNo", isEqualTo: rollNo)
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        final studentData = attendanceSnapshot.docs.first;
        final email = studentData['email'] ?? '';
        final name = studentData['name'] ?? '';

        // Check if the document already exists in the new attendance collection
        final attendanceDoc =
            _firestore.collection(attendanceCollectionName).doc(rollNo);

        final docSnapshot = await attendanceDoc.get();

        if (!docSnapshot.exists) {
          // Create a new document with default values
          await attendanceDoc.set({
            'attendance': 'Absent',
            'date': formattedDate,
            'email': email,
            'isPresent': false,
            'name': name,
          });
        }

        // Update the document to mark the student as present
        await attendanceDoc.update({
          'attendance': 'Present',
          'isPresent': true,
        });
      } else {
        debugPrint(
            "Roll number $rollNo not found in the attendancecollection.");
      }
    } catch (e) {
      debugPrint("Error marking roll number as present: $e");
    } finally {
      setState(() {
        isProcessing = false; // Reset processing state
      });
    }
  }
}
