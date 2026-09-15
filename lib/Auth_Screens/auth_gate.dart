import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/Auth_Screens/signin_screen.dart';
import 'package:tube_well/Screens/home_screen.dart';
import 'package:tube_well/Auth_Screens/signup_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          if (user.emailVerified) {
            return const HomeScreen();
          }

          return const SigninScreen();
        }

        return const SignupScreen();
      },
    );
  }
}
