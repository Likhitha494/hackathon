// lib/user_home.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ac_technicians_screen.dart';
import 'electricians_screen.dart';
import 'plumbers_screen.dart';
// Add other service screens here.

class UserHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildServiceIcon(context, 'AC Technicians', Icons.ac_unit, AcTechniciansScreen()),
          _buildServiceIcon(context, 'Electricians', Icons.electrical_services, ElectriciansScreen()),
          _buildServiceIcon(context, 'Plumbers', Icons.plumbing, PlumbersScreen()),
          _buildServiceIcon(context, 'Mechanics', Icons.build, MechanicsScreen()),
          _buildServiceIcon(context, 'Carpenters', Icons.chair, CarpentersScreen()),
          _buildServiceIcon(context, 'Technicians', Icons.engineering, TechniciansScreen()),
          _buildServiceIcon(context, 'Cleaning & Pest Control', Icons.cleaning_services, CleaningAndPestControlScreen()),
          _buildServiceIcon(context, 'Home Appliances Repair', Icons.home_repair_service, HomeAppliancesRepairScreen()),
          _buildServiceIcon(context, 'Building Painting', Icons.format_paint, BuildingPaintingScreen()),
          _buildServiceIcon(context, 'Other Services', Icons.miscellaneous_services, OtherServicesScreen()),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(BuildContext context, String label, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => screen,
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
