import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DownloadPage extends StatelessWidget {
  Future<void> downloadCollection(
      BuildContext context, String collectionName, String fileName) async {
    try {
      // Check and request storage permission
      if (!await _checkStoragePermission(context)) {
        return;
      }

      // Fetch data from Firestore collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      // Prepare CSV data
      List<List<dynamic>> csvData = [];

      // Add headers (assuming fields are consistent)
      if (documents.isNotEmpty) {
        Map<String, dynamic> firstDoc =
            documents.first.data() as Map<String, dynamic>;
        csvData.add(firstDoc.keys.toList());
      }

      // Add rows for each document
      for (var doc in documents) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        csvData.add(data.values.toList());
      }

      // Convert CSV data to string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Save file to Downloads directory
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      String filePath = '${downloadsDirectory.path}/$fileName.csv';

      // Create the file and save it
      File file = File(filePath);
      file.createSync(recursive: true);
      file.writeAsStringSync(csvString);

      // Show a success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully to: $filePath'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Show an error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _checkStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      // Permission already granted
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Request permission
      var result = await Permission.storage.request();

      if (result.isGranted) {
        return true;
      } else {
        // Show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Storage permission is required to download files. Please enable it in settings.'),
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCAF0F8),
        title: const Text(
          'Download Page',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFCAF0F8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(context, 'Electrical', 'assets/images/electrical.png',
                'electricaldownload'),
            const SizedBox(height: 20), // Space between buttons
            _buildButton(context, 'Plumbing', 'assets/images/plumbing.png',
                'plumbingdownload'),
            const SizedBox(height: 20), // Space between buttons
            _buildButton(context, 'Carpentry', 'assets/images/Carpentry.png',
                'carpentrydownload'),
            const SizedBox(height: 20), // Space between buttons
            _buildButton(context, 'Others', 'assets/images/application.png',
                'othersdownload'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, String imagePath,
      String collectionName) {
    return ElevatedButton(
      onPressed: () => downloadCollection(context, collectionName, label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(imagePath, width: 40, height: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
