import 'package:farm/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:farm/Taskbar.dart';
import 'package:farm/auth/forgot_password.dart';
// Assuming you have a ProductPage widget in 'package:farm/pages/product_page.dart'
// import 'package:farm/pages/product_page.dart'; // Uncomment and replace with your actual product page import


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailSignIn() {
    // TODO: Implement email and password sign-in logic here
    String email = _emailController.text;
    String password = _passwordController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signing in with Email: $email and Password: $password (Logic to be implemented)')),
    );
    // Example: Navigate to main page after successful sign-in
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const MainPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background to white
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
        backgroundColor: Colors.white, // AppBar background also white
        elevation: 0, // Remove shadow for a flat look
        iconTheme: const IconThemeData(color: Colors.black87), // Set back button color
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow on smaller screens
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Changed for white background
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to continue to Farme',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54, // Changed for white background
                ),
              ),
              const SizedBox(height: 40),

              // Email Text Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black87), // Changed for white background
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.grey), // Changed for white background
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 10), // Changed for white background
                  prefixIcon: const Icon(Icons.email, color: Colors.grey), // Changed for white background
                  filled: true,
                  fillColor: Colors.grey[100], // Lighter fill color for white background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.green), // Focus border color
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Text Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black87), // Changed for white background
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.grey), // Changed for white background
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Colors.grey), // Changed for white background
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Changed for white background
                  filled: true,
                  fillColor: Colors.grey[100], // Lighter fill color for white background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.green), // Focus border color
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.green)),
                ),
              ),
              const SizedBox(height: 20),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _handleEmailSignIn(); // Keep your sign-in logic
                    // Navigate to your MainScreen (with taskbar)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Primary action color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Or continue with',
                style: TextStyle(color: Colors.black54, fontSize: 12), // Changed for white background
              ),
              const SizedBox(height: 20),

           // Google and Facebook Sign-In Buttons in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space evenly
                children: [
                  Expanded( // Google Sign-In Button
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Google Sign-In logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Sign-In Clicked! (Logic to be implemented)')),
                          );
                        },
                        icon: Image.asset(
                          'lib/assets/google_720255.png', // Placeholder for Google logo
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Google', // Shorter text for row display
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!), // Add a light border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15), // Space between buttons

                  Expanded( // Facebook Sign-In Button
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Facebook Sign-In logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Facebook Sign-In Clicked! (Logic to be implemented)')),
                          );
                        },
                        icon: Image.asset(
                          'lib/assets/facebook_145802.png', // Placeholder for Facebook logo
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Facebook', // Shorter text for row display
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2), // Facebook blue
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // "Don't have an account?" and "Sign up" link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?", // Text unchanged for logical flow
                    style: TextStyle(color: Colors.black54, fontSize: 14), // Changed for white background
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to the Sign Up page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUp()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.green, // Highlight the sign-up link (changed from greenAccent for contrast)
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

