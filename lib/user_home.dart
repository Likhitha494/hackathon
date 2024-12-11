// lib/user_home.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/services/ac_service.dart';
import 'package:hackathon/services/building_painting.dart';
import 'package:hackathon/services/carpenters.dart';
import 'package:hackathon/services/cleaning__pest_control.dart';
import 'package:hackathon/services/electricians.dart';
import 'package:hackathon/services/home_appliances_repair.dart';
import 'package:hackathon/services/mechanics.dart';
import 'package:hackathon/services/other_services.dart';
import 'package:hackathon/services/plumbers.dart';
import 'package:hackathon/services/technicians.dart';
import 'package:hackathon/slpash_screen.dart';
// Add other service screens here.

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: Icon(Icons.logout)),
        ],
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
            Icon(icon, size: 48.0, color: Colors.black),
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
