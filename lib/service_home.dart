import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hackathon/slpash_screen.dart';
import 'package:url_launcher/url_launcher.dart';  // Add this package for launching SMS

class ServiceHome extends StatefulWidget {
  const ServiceHome({super.key});

  @override
  _ServiceHomeState createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedService = 'AC technicians';
  String username = ''; // Initially empty, will be fetched from Firebase
  String _contact = '';
  String _preferredDate = '';
  String _preferredTime = '';
  String _problemDescription = '';
  String _problemLocation = '';
  String _technicianName = '';

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

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUsernameFromFirestore();
    _getTemporaryBookingDetails();
  }

  // Function to fetch username from Firebase Firestore
  Future<void> _getUsernameFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid; // Fetching the user ID

        // Query the 'Users' collection using the uid as document ID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'Unknown';
          });
          if (kDebugMode) {
            print('Username found: $username');
          }
        } else {
          if (kDebugMode) {
            print('User document not found!');
          }
          setState(() {
            username = 'Unknown';
          });
        }
      } else {
        if (kDebugMode) {
          print('No user is signed in.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
      setState(() {
        username = 'Unknown';
      });
    }
  }

  // Function to fetch temporary booking details
  Future<void> _getTemporaryBookingDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!; // Get the current user's email

      try {
        // Fetching the document using the user's email from 'TemporaryBookings' collection
        DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
            .collection('TemporaryBookings')
            .doc(email) // Use email as the document ID
            .get();

        if (bookingDoc.exists) {
          setState(() {
            _contact = bookingDoc['contact'] ?? 'N/A';
            _preferredDate = bookingDoc['preferredDate'] ?? 'N/A';
            _preferredTime = bookingDoc['preferredTime'] ?? 'N/A';
            _problemDescription = bookingDoc['problemDescription'] ?? 'N/A';
            _problemLocation = bookingDoc['problemLocation'] ?? 'N/A';
            _technicianName = bookingDoc['technicianName'] ?? 'N/A';
          });
        } else {
          if (kDebugMode) {
            print('Booking document not found!');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching booking details: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('No user is signed in.');
      }
    }
  }

  // Function to send SMS for booking confirmation
  Future<void> _sendConfirmationMessage(String contact) async {
    final Uri smsUrl = Uri(
      scheme: 'sms',
      path: contact,
      queryParameters: {
        'body': 'Your booking is confirmed. Thank you for choosing our service!'
      },
    );

    if (await canLaunch(smsUrl.toString())) {
      await launch(smsUrl.toString());
    } else {
      throw 'Could not send SMS to $contact';
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Home'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Service Request'),
            Tab(text: 'Temporary Booking Details'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Service Request Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                    decoration: const InputDecoration(labelText: 'Select Service Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a service type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _contactNumberController,
                    decoration: const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your contact number';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Please enter a valid 10-digit contact number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description of Work'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'Time of Service'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the time for the service';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location of Service'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the location';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Temporary Booking Details Tab with Box Design
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                _buildBookingDetailBox('Contact', _contact),
                _buildBookingDetailBox('Preferred Date', _preferredDate),
                _buildBookingDetailBox('Preferred Time', _preferredTime),
                _buildBookingDetailBox('Problem Description', _problemDescription),
                _buildBookingDetailBox('Problem Location', _problemLocation),
                _buildBookingDetailBox('Technician Name', _technicianName),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _sendConfirmationMessage(_contact);
                    },
                    child: const Text('Confirm Booking and Send SMS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a custom styled box for each booking detail
  Widget _buildBookingDetailBox(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Handle form submission
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Process data and save to Firestore or another action
    }
  }
}
