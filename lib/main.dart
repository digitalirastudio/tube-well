import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:tube_well/Auth_Screens/splash_screen.dart';
import 'package:tube_well/core/profile_avatar.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://tube-well-ef1b0-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  await ProfileAvatarStore.load();

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
