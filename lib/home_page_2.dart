import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:hostelsync/profile.dart';
import 'noti.dart';

class HomePage2Widget extends StatefulWidget {
  const HomePage2Widget({super.key});

  @override
  State<HomePage2Widget> createState() => _HomePage2WidgetState();
}

class _HomePage2WidgetState extends State<HomePage2Widget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch user name on page load
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      String uid = user.uid;
      // Fetch the user's name from Firestore using their UID
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          userName = userDoc['name']; // Assign the name field from Firestore
        });
      }
    }
  }

  // Function to store event data in Firebase
  Future<void> _storeEventData() async {
    String eventText = _eventController.text.trim();
    DateTime currentDate = DateTime.now();

    if (eventText.isNotEmpty) {
      await FirebaseFirestore.instance.collection('events').add({
        'eventText': eventText,
        'date': currentDate.toIso8601String(),
      });

      _eventController.clear(); // Clear the text field after saving
    }
  }

  // Function to delete an event from Firebase
  Future<void> _deleteEvent(String docId) async {
    await FirebaseFirestore.instance.collection('events').doc(docId).delete();
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFCAF0F8),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to the profile page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF48CAE4),
                            image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/images/profile.gif'),
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
                        child: GradientText(
                          'HostelSync!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF00F5D4),
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                          colors: const [Color(0xFF03045E), Color(0xFF0096C7)],
                          gradientDirection: GradientDirection.rtl,
                          gradientType: GradientType.linear,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the notification page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NotificationsPage()), // Replace with your notification page widget
                          );
                        },
                        child: const Icon(
                          Icons.notifications,
                          color: Color(0xFF023E8A),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello,',
                        style: GoogleFonts.readexPro(
                          color: const Color(0xFF0096C7),
                          fontSize: 27,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName ??
                            'Loading...', // Display user's name or "Loading..." while fetching
                        style: GoogleFonts.readexPro(
                          color: const Color(0xFF023E8A),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(35, 25, 35, 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(context, 'Attendance');
                        },
                        child: Container(
                          width: 140,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF07BEB8),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Attendance',
                                  style: GoogleFonts.readexPro(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/immigration.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(context, 'Complaints');
                        },
                        child: Container(
                          width: 140,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8FAB),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 5, 0, 10),
                                  child: Text(
                                    'Complaints',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.readexPro(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 10),
                                  child: Image.asset(
                                    'assets/images/dislike.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(35, 12, 35, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(context, 'Notices');
                        },
                        child: Container(
                          width: 140,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF70D6FF),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 20),
                                  child: Text(
                                    'Instruction',
                                    style: GoogleFonts.readexPro(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 20),
                                  child: Image.asset(
                                    'assets/images/notice.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(context, 'Others');
                        },
                        child: Container(
                          width: 140,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC77DFF),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 5, 0, 8),
                                  child: Text(
                                    'Others..',
                                    style: GoogleFonts.readexPro(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 40),
                                  child: Image.asset(
                                    'assets/images/application.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Events',
                        style: GoogleFonts.readexPro(
                          color: const Color(0xFF00B4D8),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEECF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/arrow.gif',
                              width: 64,
                              height: 58,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 0, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Events',
                                  style: GoogleFonts.readexPro(
                                    color:
                                        const Color.fromARGB(255, 255, 98, 0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: TextField(
                                    controller: _eventController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter event details..',
                                      hintStyle: GoogleFonts.readexPro(
                                        color: const Color.fromARGB(
                                            255, 243, 113, 33),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: GoogleFonts.readexPro(
                                      color: const Color.fromARGB(
                                          255, 243, 113, 33),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 0, 0),
                                  child: Text(
                                    DateTime.now().toString().substring(0, 10),
                                    style: GoogleFonts.readexPro(
                                      color: const Color(0xFF999999),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _storeEventData,
                                  child: const Text('Save Event'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Display events from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var events = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        var event = events[index];
                        String eventText = event['eventText'];
                        String eventDate = event['date'];
                        String docId = event.id;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEECF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text(
                                eventText,
                                style: GoogleFonts.readexPro(
                                  color: const Color(0xFFFFA500),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                eventDate.substring(0, 10),
                                style: GoogleFonts.readexPro(
                                  color: const Color(0xFF999999),
                                  fontSize: 15,
                                ),
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteEvent(docId); // Call delete function
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
