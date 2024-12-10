import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony/telephony.dart';

class BookingPage extends StatefulWidget {
  final String name;
  final String contact;
  final String description;

  const BookingPage({
    Key? key,
    required this.name,
    required this.contact,
    required this.description,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final Telephony telephony = Telephony.instance;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Request SMS permissions
    _requestSmsPermissions();
  }

  // Request SMS sending permissions
  Future<void> _requestSmsPermissions() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS permissions are required to send confirmations')),
      );
    }
  }

  // Send SMS confirmation
  Future<void> _sendSmsConfirmation(String phoneNumber) async {
    try {
      await telephony.sendSms(
        to: phoneNumber,
        message: 'Your booking with ${widget.name} has been confirmed. '
            'Technician will contact you soon.',
      );
    } catch (e) {
      print('Failed to send SMS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send SMS confirmation: $e')),
      );
    }
  }

  // Save booking to Firestore
  Future<void> _saveBookingToFirestore(Map<String, dynamic> bookingData) async {
    try {
      await _firestore.collection('bookings').add(bookingData);
    } catch (e) {
      print('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking: $e')),
      );
    }
  }

  // Confirm booking method
  Future<void> _confirmBooking() async {
    if (_formKey.currentState!.validate()) {
      // Prepare booking data
      Map<String, dynamic> bookingData = {
        'technician_name': widget.name,
        'technician_contact': widget.contact,
        'service_description': widget.description,
        'customer_name': _nameController.text,
        'customer_phone': _phoneController.text,
        'customer_email': _emailController.text,
        'additional_notes': _additionalNotesController.text,
        'booking_timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending'
      };

      try {
        // Save to Firestore
        await _saveBookingToFirestore(bookingData);

        // Send SMS confirmation
        await _sendSmsConfirmation(_phoneController.text);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking confirmed for ${widget.name}'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _additionalNotesController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking for ${widget.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Technician: ${widget.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Contact: ${widget.contact}'),
              const SizedBox(height: 8),
              Text('Description: ${widget.description}'),
              const SizedBox(height: 16),

              // Customer Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Basic phone number validation
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Additional Notes Field
              TextFormField(
                controller: _additionalNotesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Confirm Booking Button
              ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }
}