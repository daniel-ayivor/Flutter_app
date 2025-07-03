import 'package:farm/home/welcome.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer


class Frontpage extends StatefulWidget {
  const Frontpage({super.key});

  @override
  State<Frontpage> createState() => _FrontpageState();
}

class _FrontpageState extends State<Frontpage> {
  @override
  void initState() {
    super.initState();
    // Start a timer for 5 seconds
    Timer(const Duration(seconds: 5), () {
      // Navigate to the MainPage after 5 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            // Using the provided image path
            Image.asset(
              'lib/assets/letter-f_8057804.png', // Updated logo path
              width: 150, // Adjust logo width as needed
              height: 150, // Adjust logo height as needed
              // Optional: Add a placeholder if the image fails to load
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported, // A more appropriate icon for image loading errors
                  size: 150,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 4), // Space between logo and company name, updated to 10
            Text(
              'Farme', // Updated company name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 47, 109, 79), // Updated text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}