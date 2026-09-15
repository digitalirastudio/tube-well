// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tube_well/Auth_Screens/signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tube Well',
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
                'Create your account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                obscureText: obscureConfirmPassword,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(color: Color(0xFF123B5D)),
                  filled: true,
                  fillColor: Color.fromARGB(255, 201, 232, 247),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
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
                    if (nameController.text.trim().isEmpty) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your name.'),
                        ),
                      );
                      return;
                    }
                    if (emailController.text.trim().isEmpty) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email.'),
                        ),
                      );
                      return;
                    }
                    final password = passwordController.text;

                    if (password.length < 8 ||
                        !password.contains(RegExp(r'[A-Z]')) ||
                        !password.contains(RegExp(r'[a-z]')) ||
                        !password.contains(RegExp(r'[0-9]')) ||
                        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must be 8+ characters and include uppercase, lowercase, number, and special character.',
                          ),
                        ),
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match.'),
                        ),
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                      await FirebaseAuth.instance.currentUser
                          ?.updateDisplayName(nameController.text.trim());
                      await FirebaseAuth.instance.currentUser
                          ?.sendEmailVerification();
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.code == 'email-already-in-use'
                                ? 'This email is already registered.'
                                : e.code == 'invalid-email'
                                ? 'Please enter a valid email address.'
                                : 'Sign up failed. Please try again.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninScreen(),
                      ),
                    );
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Sign Up',
                          style: TextStyle(color: Color(0xFF123B5D)),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Color(0xFF123B5D)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
