import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_page.dart'; // Import the PaymentPage

class BookingPage extends StatelessWidget {
  final String name;
  final String contact;
  final String description;
  final String email;

  const BookingPage({
    super.key,
    required this.name,
    required this.contact,
    required this.description,
    required this.email,
  });

  // Function to send SMS using url_launcher
  Future<void> _sendSms(String message) async {
    final String phoneNumber = contact;
    final Uri smsUri = Uri.parse('sms:$phoneNumber?body=$message');
    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else {
      throw 'Could not launch SMS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController problemDescriptionController =
    TextEditingController();

    // Dummy amount for the payment page
    final String totalAmount = '\$50.00'; // This can be calculated based on various factors

    void submitBooking() async {
      final bookingDetails = {
        'technicianName': name,
        'contact': contact,
        'description': description,
        'preferredDate': dateController.text,
        'preferredTime': timeController.text,
        'problemLocation': locationController.text,
        'problemDescription': problemDescriptionController.text,
        'timestamp': Timestamp.now(),
      };

      try {
        // Store booking details in Firestore using email as document ID
        await FirebaseFirestore.instance
            .collection('TemporaryBookings')
            .doc(email)
            .set(bookingDetails);

        // Send SMS with the booking details
        final smsContent = '''
Booking Details:
Technician: $name
Contact: $contact
Description: $description
Preferred Date: ${dateController.text}
Preferred Time: ${timeController.text}
Problem Location: ${locationController.text}
Problem Description: ${problemDescriptionController.text}
''';

        _sendSms(smsContent);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking submitted successfully!')),
        );
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit booking: $e')),
        );
      }
    }

    void goToPaymentPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            technicianName: name,
            totalAmount: totalAmount,
            submitBooking: submitBooking, // Pass submitBooking function to PaymentPage
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Book $name'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Technician Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Name: $name'),
            Text('Contact: $contact'),
            Text('Description: $description'),
            const SizedBox(height: 16),
            const Text(
              'Booking Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Preferred Date',
                hintText: 'Enter a date (e.g., 2024-12-10)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Preferred Time',
                hintText: 'Enter a time (e.g., 10:30 AM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Problem Location',
                hintText: 'Enter the address or location details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: problemDescriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Problem Description',
                hintText: 'Briefly describe the issue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: goToPaymentPage,

                // Navigate to PaymentPage

                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
