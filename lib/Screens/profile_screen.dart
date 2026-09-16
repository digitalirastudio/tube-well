import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/core/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String getUserName() {
    final name = FirebaseAuth.instance.currentUser?.displayName?.trim();
    return (name != null && name.isNotEmpty) ? name : 'User';
  }

  String getUserEmail() {
    final email = FirebaseAuth.instance.currentUser?.email?.trim();
    return (email != null && email.isNotEmpty) ? email : 'No email found';
  }

  @override
  Widget build(BuildContext context) {
    final userName = getUserName();
    final userEmail = getUserEmail();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 232, 247),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 24.0, right: 24.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Choose your profile emoji',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF123B5D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 5,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              children: ProfileAvatarStore.emojis.map((emoji) {
                                return GestureDetector(
                                  onTap: () {
                                    ProfileAvatarStore.select(emoji);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF123B5D)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: ProfileAvatarStore.selectedEmoji,
                        builder: (context, emoji, _) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF123B5D)
                                .withValues(alpha: 0.12),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 72),
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF123B5D),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B5D),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF123B5D).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
