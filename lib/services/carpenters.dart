import 'package:flutter/material.dart' show AppBar, BuildContext, Card, Center, CircularProgressIndicator, Column, ConnectionState, CrossAxisAlignment, EdgeInsets, FontWeight, ListTile, ListView, Scaffold, StatelessWidget, StreamBuilder, Text, TextStyle, Widget;
import 'package:cloud_firestore/cloud_firestore.dart';

class CarpentersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpenters'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Carpenters').snapshots(),
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

          // Extracting documents from snapshot
          final technicians = snapshot.data!.docs;

          return ListView.builder(
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final technician = technicians[index];
              final data = technician.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final contact = data['contact'] ?? 'No contact info'; // Assumes "contact" is a field
              final description = data['description'] ?? 'No description';
              final amount = data['amount'] ?? 'No amount';
              final time = data['time'] ?? 'No time';
              final location = data['location'] ?? 'No location';

              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: $contact'),
                      Text('Description: $description'),
                      Text('Amount: $amount'),
                      Text('Time: $time'),
                      Text('Location: $location'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
