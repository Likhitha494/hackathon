import 'dart:async';

import 'package:flutter/material.dart';

import 'login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<Map<String, String>> content = [
    {
      'animation': 'assets/1.json', // Replace with valid Lottie asset paths
      'title': 'Hello, I’m ZETAONE ,Your Trusted Partner for Services.',
      'paragraph': 'My mission is to streamline maintenance tasks with easy scheduling, real-time updates, and reminders. It’s your go-to tool for staying organized and ensuring top-notch service, anytime and anywhere.'
    },
    {
      'animation': 'assets/2.json',
      'title': 'Comprehensive Listings and Transparent Reviews. ',
      'paragraph': 'Access a wide range of services categorized by type, with detailed descriptions, pricing, and availability.Empowered decision-making through user reviews and ratings that reflect quality and reliability',
    },
    {
      'animation': 'assets/4.json',
      'title': 'Smart Scheduling with Location Matching.',
      'paragraph':  'Instant booking or scheduling options with calendar integration and reminders for seamless appointment management.GPS-enabled tracking connects users to nearby service providers for fast and efficient service delivery.',
    },
    {
      'animation': 'assets/3.json',
      'title': 'Secure Payment and Invoice Tracking',
      'paragraph': 'Multiple payment options with secure gateways ensure hassle-free transactions.Automatic invoice generation and tracking for added convenience.',
    },
  ];

  int _currentPage = 0;
  late PageController _pageController;
  late Timer _timer;

  get onTap => null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Auto-slide timer
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < content.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first page after the last page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Common background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Background1.jpg'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // PageView with content
          FractionallySizedBox(
            heightFactor: 0.8,
            child: PageView.builder(
              controller: _pageController,
              itemCount: content.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return FractionallySizedBox(
                  widthFactor: 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lottie animation
                      Text("VAP Team"),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        content[index]['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Paragraph
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          content[index]['paragraph']!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // "Get Started" Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dots Indicator
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                content.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blueAccent : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
