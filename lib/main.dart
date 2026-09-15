import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tube_well/Auth_Screens/splash_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TubeWell());
}

class TubeWell extends StatelessWidget {
  const TubeWell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tube Well',
      home: const SplashScreen(),
    );
  }
}
