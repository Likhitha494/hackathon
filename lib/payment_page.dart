import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String technicianName;
  final String totalAmount;
  final Function submitBooking;

  const PaymentPage({
    super.key,
    required this.technicianName,
    required this.totalAmount,
    required this.submitBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Technician: $technicianName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Amount: $totalAmount',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulate payment success
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Successful')),
                );

                // Proceed to submit booking after payment success
                submitBooking();

                // Navigate back to the BookingPage
                Navigator.pop(context);
              },
              child: const Text('Proceed to Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
