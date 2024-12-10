import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../book_page.dart';

class AcTechniciansScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AC Technicians'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('AC technicians').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          final technicians = snapshot.data!.docs;

          return ListView.builder(
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final technician = technicians[index];
              final data = technician.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final contact = data['contact'] ?? 'No contact info';
              final description = data['description'] ?? 'No description';
              final amount = data['amount'] ?? 'No amount';
              final time = data['time'] ?? 'No time';
              final location = data['location'] ?? 'No location';
              final email = data['email'] ?? 'No email';

              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(description, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: $contact'),
                      Text('Amount: $amount'),
                      Text('Time: $time'),
                      Text('Location: $location'),
                    ],
                  ),
                  onTap: () {
                    _showDetailsDialog(
                      context,
                      name,
                      contact,
                      description,
                      amount,
                      time,
                      location,
                      email, // Pass email here
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetailsDialog(BuildContext context,
      String name,
      String contact,
      String description,
      String amount,
      String time,
      String location,
      String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact: $contact'),
              Text('Description: $description'),
              Text('Amount: $amount'),
              Text('Time: $time'),
              Text('Location: $location'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      name: name,
                      contact: contact,
                      description: description,
                      email: email, // Pass email to the booking page
                    ),
                  ),
                );
              },
              child: Text('Book'),
            ),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse('tel:$contact');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to make a call')),
                  );
                }
              },
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }
}
