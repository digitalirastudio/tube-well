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
      backgroundColor: const Color(0xFF123B5D),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              color: const Color(0xFF123B5D),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      size: 40,
                      color: Color.fromARGB(255, 201, 232, 247),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TubeWell',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 201, 232, 247),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 252, 254, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),

                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Get Started with TubeWell',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF123B5D),
                          ),
                        ),
                        const SizedBox(height: 30),

                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: const TextStyle(
                              color: Color(0xFF123B5D),
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF123B5D),
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                            labelStyle: const TextStyle(
                              color: Color(0xFF123B5D),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF123B5D),
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                            labelStyle: const TextStyle(
                              color: Color(0xFF123B5D),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF123B5D),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF123B5D),
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
                            labelStyle: const TextStyle(
                              color: Color(0xFF123B5D),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                              color: Color(0xFF123B5D),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF123B5D),
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF123B5D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                                  !password.contains(
                                    RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                                  )) {
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
                                    ?.updateDisplayName(
                                      nameController.text.trim(),
                                    );
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
                                    style: TextStyle(color: Colors.white),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
