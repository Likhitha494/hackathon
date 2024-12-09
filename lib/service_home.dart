import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ServiceHome extends StatefulWidget {
  @override
  _ServiceHomeState createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedService = 'AC technicians';
  String username = '';  // Initially empty, will be fetched from Firebase

  // List of available services
  final List<String> _services = [
    'AC technicians',
    'Electricians',
    'Plumbers',
    'Mechanics',
    'Carpenters',
    'Technicians',
    'Cleaning and Pest control',
    'Home appliances repair',
    'Building paintings',
    'Other service providers'
  ];

  @override
  void initState() {
    super.initState();
    _getUsernameFromFirestore();
  }

  // Function to fetch username from Firebase Firestore
  Future<void> _getUsernameFromFirestore() async {
    try {
      // Get the current user's uid
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;  // Fetching the user ID

        // Query the 'Users' collection using the uid as document ID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)  // Using uid as the document ID
            .get();

        if (userDoc.exists) {
          // Fetch the 'username' field from the document
          setState(() {
            username = userDoc['username'] ?? 'Unknown';  // Default to 'Unknown' if no username field
          });
          print('Username found: $username'); // Debugging: Check the username value
        } else {
          print('User document not found!');
          setState(() {
            username = 'Unknown';
          });
        }
      } else {
        print('No user is signed in.');
      }
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Unknown';
      });
    }
  }

  // Function to submit form data to Firebase
  Future<void> _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? email = user.email;  // Get the current user's email
      print('User email: $email');

      // If email is not null or empty, proceed with submitting the service request
      if (_formKey.currentState!.validate()) {
        try {
          // If the email is available, proceed to submit service request
          DocumentReference serviceDoc = FirebaseFirestore.instance
              .collection(_selectedService)  // Collection based on service type
              .doc(email);  // Use email as the document ID

          // Set the service request data with user's email
          await serviceDoc.set({
            'email': email,  // Store email as a field
            'description': _descriptionController.text,
            'amount': _amountController.text,
            'time': _timeController.text,
            'location': _locationController.text,
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Service request submitted successfully')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')));
        }
      }
    } else {
      print('No user is signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Dropdown for selecting service type
              DropdownButtonFormField<String>(
                value: _selectedService,
                onChanged: (value) {
                  setState(() {
                    _selectedService = value!;
                  });
                },
                items: _services.map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Service Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service type';
                  }
                  return null;
                },
              ),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description of Work'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              // Time field
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Time of Service'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the time for the service';
                  }
                  return null;
                },
              ),
              // Location field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location of Service'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
