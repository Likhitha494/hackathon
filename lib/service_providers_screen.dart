import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvidersScreen extends StatelessWidget {
  final String serviceType;

  const ServiceProvidersScreen({Key? key, required this.serviceType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceType),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('AcTechnicians')
            .get(),
        builder: (context, snapshot) {
          // Check connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Check for errors
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Check if data exists
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No service providers found'),
            );
          }

          // Get the documents
          final serviceProviders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: serviceProviders.length,
            itemBuilder: (context, index) {
              // Get the document data
              final provider = serviceProviders[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    provider['name'] ?? 'AC Technician',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${provider['amount']}'),
                      Text('Description: ${provider['description']}'),
                      Text('Email: ${provider['email']}'),
                      Text('Location: ${provider['location']}'),
                      Text('Time: ${provider['time']}'),
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