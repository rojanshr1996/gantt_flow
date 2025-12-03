import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gantt_mobile/screens/auth/login_screen.dart';
import 'package:gantt_mobile/screens/home/home_screen.dart';

/// Checks the changes in firebase auth instance in order to navigate user to either home screen or login screen
class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // Check if user has an active session
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      debugPrint("Firebase user exists, checking session validity");
      // User exists in Firebase, but we need to verify Google session is still valid
      // The StreamBuilder will handle the navigation
    } else {
      debugPrint("No Firebase user found");
    }

    setState(() {
      _isCheckingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            debugPrint("User authenticated, navigating to HomeScreen");
            return const HomeScreen();
          } else {
            debugPrint("No authenticated user, navigating to LoginScreen");
            return const LoginScreen();
          }
        });
  }
}
