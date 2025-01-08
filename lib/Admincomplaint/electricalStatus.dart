import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectricalListPage extends StatefulWidget {
  @override
  _ElectricalListPageState createState() => _ElectricalListPageState();
}

class _ElectricalListPageState extends State<ElectricalListPage> {
  final CollectionReference complaintsCollection =
      FirebaseFirestore.instance.collection('electricalcomplaints');
  final CollectionReference complaintStatusCollection =
      FirebaseFirestore.instance.collection('electrical_status');

  // Function to remove complaint and add status
  Future<void> _handleComplaintChecked(String complaintId, String email) async {
    try {
      // Retrieve the complaint document
      DocumentSnapshot complaintDoc =
          await complaintsCollection.doc(complaintId).get();

      if (!complaintDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint does not exist!')),
        );
        return;
      }

      // Extract the 'complaint' field and other relevant fields
      String complaintText = complaintDoc['complaint'];

      // Add the email, status, and complaint text to complaint_status collection
      await complaintStatusCollection.add({
        'email': email,
        'status': 'Completed',
        'complaint': complaintText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove the complaint from complaints collection
      await complaintsCollection.doc(complaintId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint handled successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling complaint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints List'),
        backgroundColor: Color(0xFFCAF0F8),
      ),
      body: Container(
        color: Color(0xFFCAF0F8),
        child: StreamBuilder(
          stream: complaintsCollection.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final complaints = snapshot.data!.docs;

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                var complaint = complaints[index];
                String name = complaint['name'];
                String roomNo = complaint['roomNo'];
                String complaintText = complaint['complaint'];
                String email = complaint['email'];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('$name (Room No: $roomNo)'),
                    subtitle: Text(complaintText),
                    trailing: Checkbox(
                      value: false,
                      onChanged: (bool? value) {
                        if (value == true) {
                          _handleComplaintChecked(complaint.id, email);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
