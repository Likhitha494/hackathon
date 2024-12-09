// lib/user_home.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'service_providers_screen.dart';

class UserHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          _buildServiceIcon(context, 'AC Technicians', Icons.ac_unit, 'AC Technicians'),
          _buildServiceIcon(context, 'Electricians', Icons.electrical_services, 'Electricians'),
          _buildServiceIcon(context, 'Plumbers', Icons.plumbing, 'Plumbers'),
          _buildServiceIcon(context, 'Mechanics', Icons.build, 'Mechanics'),
          _buildServiceIcon(context, 'Carpenters', Icons.chair, 'Carpenters'),
          _buildServiceIcon(context, 'Technicians', Icons.engineering, 'Technicians'),
          _buildServiceIcon(context, 'Cleaning & Pest Control', Icons.cleaning_services, 'Cleaning & Pest Control'),
          _buildServiceIcon(context, 'Home Appliances Repair', Icons.home_repair_service, 'Home Appliances Repair'),
          _buildServiceIcon(context, 'Building Painting', Icons.format_paint, 'Building Painting'),
          _buildServiceIcon(context, 'Other Services', Icons.miscellaneous_services, 'Other Services'),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(BuildContext context, String label, IconData icon, String serviceType) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceProvidersScreen(serviceType: serviceType),
        ),
      ),
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Colors.blue),
            SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}