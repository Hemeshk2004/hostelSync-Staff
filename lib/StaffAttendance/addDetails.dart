import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentDetailsPage extends StatefulWidget {
  const AddStudentDetailsPage({super.key});

  @override
  _AddStudentDetailsPageState createState() => _AddStudentDetailsPageState();
}

class _AddStudentDetailsPageState extends State<AddStudentDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _roomNoController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _addStudent() async {
    String roomNo = _roomNoController.text.trim();
    String rollNo = _rollNoController.text.trim();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (roomNo.isNotEmpty &&
        rollNo.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty) {
      await _firestore.collection('attendancecollection').add({
        'roomNo': roomNo,
        'rollNo': rollNo,
        'name': name,
        'email': email,
      });

      // Clear the input fields
      _roomNoController.clear();
      _rollNoController.clear();
      _nameController.clear();
      _emailController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student details added successfully!')),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Student Details'),
          backgroundColor: const Color(0xFFCAF0F8)),
      backgroundColor: const Color(0xFFCAF0F8),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            TextField(
              controller: _roomNoController,
              decoration: InputDecoration(
                labelText: 'Room No',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rollNoController,
              decoration: InputDecoration(
                labelText: 'Roll No',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03045E), // Button color
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: Text(
                'Add Student',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
