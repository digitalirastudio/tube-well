// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tube_well/Screens/home_screen.dart';
import 'package:tube_well/Screens/signup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(color: Color(0xFF123B5D)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF123B5D)),
                  filled: true,
                  fillColor: Color.fromARGB(255, 201, 232, 247),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFF123B5D)),
                  filled: true,
                  fillColor: Color.fromARGB(255, 201, 232, 247),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final email = emailController.text.trim();

                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your email first.'),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent.'),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.code == 'invalid-email'
                              ? 'Please enter a valid email address.'
                              : 'Could not send password reset email.',
                        ),
                      ),
                    );
                  }
                  // Password reset will go here
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF123B5D)),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email.'),
                        ),
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your password.'),
                        ),
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please verify your email before signing in.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.code == 'invalid-credential'
                                ? 'Incorrect email or password.'
                                : e.code == 'invalid-email'
                                ? 'Please enter a valid email address.'
                                : 'Sign in failed. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Sign In',
                          style: TextStyle(color: Color(0xFF123B5D)),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Color(0xFF123B5D)),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.currentUser
                            ?.sendEmailVerification();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email sent again.'),
                          ),
                        );
                      },
                      child: const Text(
                        'Resend Verification Email',
                        style: TextStyle(color: Color(0xFF123B5D)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
