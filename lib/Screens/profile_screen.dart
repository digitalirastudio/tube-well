import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tube_well/Auth_Screens/signin_screen.dart';
import 'package:tube_well/Services/database_service.dart';
import 'package:tube_well/Screens/customers_screen.dart';
import 'package:tube_well/Screens/home_screen.dart';
import 'package:tube_well/Screens/transaction_screen.dart';
import 'package:tube_well/core/profile_avatar.dart';

String getDeleteAccountErrorMessage(FirebaseAuthException e) {
  if (e.code == 'requires-recent-login') {
    return 'Please sign in again and then try deleting your account.';
  }

  return 'Could not delete account. Please try again.';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeletingAccount = false;

  String getUserName() {
    final name = FirebaseAuth.instance.currentUser?.displayName?.trim();
    return (name != null && name.isNotEmpty) ? name : 'User';
  }

  String getUserEmail() {
    final email = FirebaseAuth.instance.currentUser?.email?.trim();
    return (email != null && email.isNotEmpty) ? email : 'No email found';
  }

  Future<String?> _promptForPassword() async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Re-enter your password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return password?.trim().isNotEmpty == true ? password : null;
  }

  void _navigateToTab(int index) {
    final screens = [
      const HomeScreen(),
      const TransactionScreen(),
      const CustomersScreen(),
      const ProfileScreen(),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screens[index]),
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? const Color(0xFF123B5D) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF123B5D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
        (route) => false,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data. '
          'This includes customers, runs, payments, and profile data. '
          'This action cannot be undone. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingAccount = true);

    try {
      final userUid = user.uid;

      // Re-authenticate first if Firebase requires it.
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          final password = await _promptForPassword();

          if (password == null || password.isEmpty) {
            throw FirebaseAuthException(
              code: 'cancelled',
              message: 'Password is required to delete the account.',
            );
          }

          final email = user.email;

          if (email == null || email.isEmpty) {
            throw FirebaseAuthException(
              code: 'invalid-email',
              message: 'No email address is associated with this account.',
            );
          }

          final credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );

          await user.reauthenticateWithCredential(credential);
        } else {
          rethrow;
        }
      }

      // Delete all Realtime Database data while the user is
      // still signed in.
      await DatabaseService().deleteUserData(userUid);

      // Now delete the Firebase Auth account.
      await user.delete();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(getDeleteAccountErrorMessage(e))));
    } catch (e) {
      debugPrint('DELETE ACCOUNT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
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
          child: Column(
            children: [
              Align(
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
                                  children: ProfileAvatarStore.emojis.map((
                                    emoji,
                                  ) {
                                    return GestureDetector(
                                      onTap: () {
                                        ProfileAvatarStore.select(emoji);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF123B5D)
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            emoji,
                                            style: const TextStyle(
                                              fontSize: 30,
                                            ),
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
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: _isDeletingAccount ? null : _deleteAccount,
                    icon: _isDeletingAccount
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    label: Text(
                      _isDeletingAccount ? 'Deleting...' : 'Delete Account',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _navigateToTab(0),
              child: _bottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: false,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToTab(1),
              child: _bottomNavItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Transactions',
                active: false,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToTab(2),
              child: _bottomNavItem(
                icon: Icons.people_rounded,
                label: 'Customers',
                active: false,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToTab(3),
              child: _bottomNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
