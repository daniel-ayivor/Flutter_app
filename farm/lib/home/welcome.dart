import 'package:farm/auth/signin.dart';
import 'package:flutter/material.dart';



class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            // Image on top
            Image.asset(
              'lib/assets/letter-f_8057804.png', // Reusing the image path
              width: 180, // Adjusted width for a welcome screen
              height: 180, // Adjusted height for a welcome screen
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported, // Fallback icon
                  size: 180,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 26), // Space between image and title
            // Title beneath the image
            const Text(
              'Welcome to Farme', // Main title
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10), // Space between title and subtitle
            // Subtitle beneath the title
            const Text(
              'Your guide to modern agriculture, where you are able to purchase all farm products.', // Subtitle
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40), // Space between subtitle and button
            // Button to navigate to Sign In page
            ElevatedButton(
              onPressed: () {
                // Navigate to the SignInPage on button click
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners for the button
                ),
                elevation: 5, // Shadow effect
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
