// lib/service_providers_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvidersScreen extends StatelessWidget {
  final String serviceType;

  ServiceProvidersScreen({required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceType),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Service Type') // Correct collection name
            .where('serviceType', isEqualTo: serviceType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No service details found'));
          }

          final serviceDetails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: serviceDetails.length,
            itemBuilder: (context, index) {
              var service = serviceDetails[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(service['serviceType']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${service['workDescription']}'),
                      Text('Time of Work: ${service['timeOfWork']}'),
                      Text('Amount: \$${service['amount']}'),
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