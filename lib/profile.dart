import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? rollNo;
  String? email;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    try {
      // Get the current user's email
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null) {
        // Query Firestore collection to match the email
        final querySnapshot = await FirebaseFirestore.instance
            .collection('appuser')
            .where('email', isEqualTo: userEmail)
            .get();

        print('Query Snapshot: ${querySnapshot.docs.length}'); // Debugging

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;

          setState(() {
            name = userDoc['name'];
            rollNo = userDoc['rollNo'];
            email = userDoc['email'];
          });
        } else {
          print('No user found for email: $userEmail'); // Debugging
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  // Method to log out the user
  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/login'); // Navigate to login page
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCAF0F8), // Set background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Center the content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Navigate back when pressed
                },
              ),
            ),

            // Profile Image Circle
            Container(
              width: 120, // Set size of circle
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue, // Placeholder color
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/profile.gif'), // Replace with the user's image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Name, Roll No, Email below image
            name == null || rollNo == null || email == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Text(
                        name ?? 'Name not available',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        rollNo ?? 'Roll No not available',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        email ?? 'Email not available',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

            // Logout GIF Image
            SizedBox(height: 200),
            GestureDetector(
              onTap: logout, // Trigger logout when the GIF is clicked
              child: Container(
                child: Text("Logout", style: TextStyle(fontSize: 10)),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/logout.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
