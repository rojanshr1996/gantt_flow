import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as google_api;
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServiceProvider extends ChangeNotifier {
  bool _authWaiting = false;

  /// Google sign in scopes for asking permissions to the user. Calendar and Drive permissions are required to use the app
  final googleSignIn = GoogleSignIn(scopes: <String>[
    gdrive.DriveApi.driveScope,
    google_api.CalendarApi.calendarScope,
    google_api.CalendarApi.calendarReadonlyScope,
    google_api.CalendarApi.calendarEventsScope,
    google_api.CalendarApi.calendarEventsReadonlyScope,
  ]);

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  /// getter and setter for loader animation
  bool get authWaiting => _authWaiting;
  set authWaiting(bool data) {
    _authWaiting = data;
    notifyListeners();
  }

  /// Check if user is already signed in and session is valid
  Future<bool> checkSession() async {
    try {
      // Check if Firebase user exists
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint("No Firebase user found");
        return false;
      }

      // Try to sign in silently with Google
      final googleUser = await googleSignIn.signInSilently();
      if (googleUser == null) {
        debugPrint("Silent sign in failed - session expired");
        await logout();
        return false;
      }

      _user = googleUser;
      debugPrint("Session valid for user: ${_user?.email}");

      // Verify the token is still valid
      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null) {
        debugPrint("Access token is null - session expired");
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      debugPrint("Session check failed: $e");
      await logout();
      return false;
    }
  }

  /// Implement google sign in API and save the data in provider
  Future googleLogIn() async {
    try {
      debugPrint("Open google sign in");
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Google sign in cancelled by user");
        return "cancelled";
      }

      _user = googleUser;
      debugPrint("User signed in: ${_user?.email}");

      final userJson = userData(_user);
      debugPrint("User info: $userJson");

      // Save the authentication response from google API to the provider
      await saveAuthInfo(json.encode(userJson));

      await saveAuthHeaderInfo(_user!);
      final googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint("Failed to get authentication tokens");
        showToast(
            message: "Failed to get authentication tokens. Please try again.");
        return "exception";
      }

      debugPrint("Creating Firebase credential");
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final data = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint("Successfully signed in with Firebase: ${data.user?.email}");
      notifyListeners();
      return data;
    } on PlatformException catch (e) {
      debugPrint("Platform exception during sign in: ${e.code} - ${e.message}");
      if (e.code == 'sign_in_canceled') {
        return "cancelled";
      }
      showToast(message: "Sign in error. Please try again.");
      return "exception";
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase auth exception: ${e.code} - ${e.message}");
      showToast(message: "Authentication failed. Please try again.");
      return "exception";
    } catch (error) {
      debugPrint("Unexpected sign in error: $error");
      showToast(message: "Sign in error. Please try again.");
      return "exception";
    }
  }

  /// Silently login the user in order to refresh and generate new accesstoken for continous app usage
  Future refreshToken() async {
    try {
      final googleUser =
          await googleSignIn.signInSilently(reAuthenticate: true);
      debugPrint("This is the google user: $googleUser");
      if (googleUser == null) {
        debugPrint("Silent sign in failed - user needs to log in again");
        return "exception";
      }
      _user = googleUser;

      final userJson = userData(_user);
      await saveAuthInfo(json.encode(userJson));
      await saveAuthHeaderInfo(_user!);

      final googleAuth = await googleUser.authentication;
      debugPrint("ACCESS TOKEN: ${googleAuth.accessToken}");

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint("Failed to get authentication tokens during refresh");
        return "exception";
      }

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final data = await FirebaseAuth.instance.signInWithCredential(credential);
      return data;
    } on PlatformException catch (e) {
      debugPrint("Refresh Token Platform exception: ${e.message}");
      showToast(message: "${e.message}");
      return "exception";
    } catch (error) {
      debugPrint(error.toString());
      showToast(message: "Request failed. Please try again.");
      return "exception";
    }
  }

  /// Log out API from google and firbase instance
  Future logout() async {
    try {
      debugPrint("Logging out user");
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      // Clear auth data but preserve calendar selections
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.remove("authUser");
      await sharedPreferences.remove("authUserHeader");
      // Keep calendarList and calendarEventList so user doesn't have to re-add calendars
      // await sharedPreferences.remove("calendarList");
      // await sharedPreferences.remove("calendarEventList");

      _user = null;
      notifyListeners();
      debugPrint("User logged out successfully");
    } on PlatformException catch (e) {
      debugPrint(e.message);
      showToast(message: "${e.message}");
      return "exception";
    } catch (e) {
      debugPrint(e.toString());
      showToast(message: "Log out Failed. Please try again.");
      return "exception";
    }
  }

  /// Save user login json response in sharedPreferences
  Future<void> saveAuthInfo(String user) async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    sharedPreference.setString("authUser", user);
  }

  /// Save user authentication header information in shared Preferences
  Future<void> saveAuthHeaderInfo(GoogleSignInAccount user) async {
    final Map<String, String> headerInfo = await user.authHeaders;
    debugPrint(headerInfo.toString());
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("authUserHeader", json.encode(headerInfo));
  }

  /// Json model for savign user information
  Map<String, String> userData(GoogleSignInAccount? user) {
    return {
      "id": user?.id ?? "",
      "display_name": user?.displayName ?? "",
      "email": user?.email ?? "",
      "photo_url": user?.photoUrl ?? ""
    };
  }
}
