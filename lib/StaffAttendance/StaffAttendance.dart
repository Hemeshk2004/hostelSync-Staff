import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StaffAttendancePage extends StatefulWidget {
  const StaffAttendancePage({super.key});

  @override
  _StaffAttendancePageState createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentDate;
  Map<String, List<Map<String, dynamic>>> _rooms = {};
  Map<String, List<Map<String, dynamic>>> _filteredRooms = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentDate = DateFormat('yyyyMMdd').format(DateTime.now());
    _fetchAttendanceData();
    _filteredRooms = Map.from(_rooms);
    _searchController.addListener(_filterRooms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendanceData() async {
    QuerySnapshot snapshot =
        await _firestore.collection('attendancecollection').get();
    QuerySnapshot attendanceSnapshot =
        await _firestore.collection('Attendance$_currentDate').get();

    // Create a map to track already marked attendance
    Map<String, bool> attendanceStatus = {
      for (var doc in attendanceSnapshot.docs)
        doc.id: (doc.data() as Map<String, dynamic>)['attendance'] == 'Present'
    };

    setState(() {
      _rooms.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String roomNo = data['roomNo'] ?? 'Unknown Room';
        String rollNo = data['rollNo'];

        if (!_rooms.containsKey(roomNo)) {
          _rooms[roomNo] = [];
        }

        // Check if the student is already marked as present
        data['isPresent'] = attendanceStatus[rollNo] ?? false;
        _rooms[roomNo]!.add(data);
      }
      _filteredRooms = Map.from(_rooms);
    });
  }

  void _filterRooms() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRooms = Map.from(_rooms);
      } else {
        _filteredRooms = {
          for (var entry in _rooms.entries)
            if (entry.key.toLowerCase().contains(query) ||
                entry.value.any(
                    (student) => student['name'].toLowerCase().contains(query)))
              entry.key: entry.value
                  .where((student) =>
                      student['name'].toLowerCase().contains(query) ||
                      entry.key.toLowerCase().contains(query))
                  .toList(),
        };
      }
    });
  }

  Future<void> _submitAttendance() async {
    for (var entry in _rooms.entries) {
      for (var student in entry.value) {
        bool isPresent = student['isPresent'] ?? false;
        await _firestore
            .collection('Attendance$_currentDate')
            .doc(student['rollNo'])
            .set({
          'name': student['name'],
          'email': student['email'],
          'attendance': isPresent ? 'Present' : 'Absent',
          'date': _currentDate,
        });
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance Submitted Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Attendance'),
        backgroundColor: const Color(0xFFCAF0F8),
      ),
      backgroundColor: const Color(0xFFCAF0F8),
      body: Column(
        children: [
          // SearchBar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Rooms or Students',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredRooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    children: _filteredRooms.entries.map((entry) {
                      String roomNo = entry.key;
                      List<Map<String, dynamic>> students = entry.value;
                      return Card(
                        margin: const EdgeInsets.all(12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room No: $roomNo',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Column(
                                children: students.map((student) {
                                  return ListTile(
                                    title: Text(
                                      student['name'],
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    subtitle: Text(
                                      'Roll No: ${student['rollNo']}',
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 16),
                                    ),
                                    trailing: Checkbox(
                                      value: student['isPresent'] ?? false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          student['isPresent'] = value!;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitAttendance,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.check),
      ),
    );
  }
}
