// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tube_well/Auth_Screens/signup_screen.dart';
import 'package:tube_well/Screens/home_screen.dart';

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
      backgroundColor: const Color(0xFF123B5D),
      //appbar

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final headerHeight = 180.0;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: headerHeight,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  color: const Color(0xFF123B5D),
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
                      padding: const EdgeInsets.only(bottom: 24),
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
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF123B5D),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                      content: Text(
                                        'Please enter your password.',
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passwordController.text
                                            .trim(),
                                      );
                                  if (!FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .emailVerified) {
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0xFF123B5D)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    ' or ',
                                    style: TextStyle(
                                      color: Color(0xFF123B5D),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0xFF123B5D)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF123B5D),
                                      side: const BorderSide(
                                        color: Color(0xFF123B5D),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Create New Account",
                                      style: TextStyle(
                                        color: Color(0xFF123B5D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final email = emailController.text.trim();

                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter your email first.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(email: email);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password reset email sent.',
                                              ),
                                            ),
                                          );
                                    } on FirebaseAuthException catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                e.code == 'invalid-email'
                                                    ? 'Please enter a valid email address.'
                                                    : 'Could not send password reset email.',
                                              ),
                                            ),
                                          );
                                    }
                                  },
                                  child: const Text(
                                    'Forgot Password?',
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
                                        content: Text(
                                          'Verification email sent again.',
                                        ),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
