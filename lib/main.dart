import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hostelsync/Login%20Signup/Screen/login.dart';
import 'package:hostelsync/StaffAttendance/DownloadAttendance.dart';
import 'package:hostelsync/StaffAttendance/StaffAttendance.dart';
import 'package:hostelsync/StaffAttendance/addDetails.dart';
import 'package:hostelsync/home_page_2.dart';
import 'package:hostelsync/complaintscreen.dart';
import 'Admincomplaint/carpentryStaus.dart';
import 'Admincomplaint/electricalStatus.dart';
import 'Admincomplaint/otherStatus.dart';
import 'Admincomplaint/plumbingStatus.dart';
import 'StaffAttendance/AttendanceAnalyze.dart';
import 'StaffAttendance/attendanceScreen.dart';
import 'package:hostelsync/othersScreen.dart';
import 'Admincomplaint/downloadPage.dart';
import 'Chat App/ChatPage.dart';
import 'package:hostelsync/scanPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // Use the AuthWrapper as the home screen
      routes: {
        'Complaints': (context) => const CompliantScreen(),
        'Attendance': (context) => const AttendanceScreen(),
        'Notices': (context) => ChatPage(),
        'Others': (context) => OthersScreenPage(),
        'Electrical': (context) => ElectricalListPage(),
        'Plumbing': (context) => PlumbingListPage(),
        'Carpentry': (context) => CarpentryListPage(),
        'Otherscom': (context) => OthersListPage(),
        'TakeAttendance': (context) => StaffAttendancePage(),
        'DownloadAttendance': (context) => ExportAttendancePage(),
        'AddStudent': (context) => AddStudentDetailsPage(),
        'OthersAtt': (context) => AttendanceAnalyze(),
        'downloadPage': (context) => DownloadPage(),
        '/login': (context) => LoginScreen(),

        // Add other routes here if needed
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the authentication state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is authenticated, go to the HomeScreen
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const HomePage2Widget();
          } else {
            return const LoginScreen(); // Navigate to login screen if not signed in
          }
        } else {
          // Show a loading indicator while Firebase is loading
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
