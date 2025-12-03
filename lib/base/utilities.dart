import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utilities {
  static const bool debug = true;

  static void doubleBack(BuildContext context) {
    Utilities.closeActivity(context);
    Utilities.closeActivity(context);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static FadeInImage fadeInImage(
      {double? height,
      double? width,
      required String image,
      required String placeholderPath}) {
    return FadeInImage.assetNetwork(
      width: width,
      height: height,
      placeholder: placeholderPath,
      image: image,
      fit: BoxFit.cover,
    );
  }

  static double screenWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth;
  }

  static double screenHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight;
  }

  static Orientation screenOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> getSnackBar(
      {required BuildContext context, required SnackBar snackBar}) {
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<String> getPreferences(String key) async {
    return ((await SharedPreferences.getInstance()).getString(key)) ?? "";
  }

  static Future setPreferences(String key, String value) async {
    (await SharedPreferences.getInstance()).setString(key, value);
  }

  static Future<bool> getBoolPreferencesWithFallback(
      String key, bool fallback) async {
    return ((await SharedPreferences.getInstance()).getBool(key)) ?? fallback;
  }

  static Future<bool> getBoolPreferences(String key) async {
    return ((await SharedPreferences.getInstance()).getBool(key)) ?? false;
  }

  static Future setBoolPreferences(String key, bool value) async {
    (await SharedPreferences.getInstance()).setBool(key, value);
  }

  static Future<int> getIntPreferences(String key) async {
    return ((await SharedPreferences.getInstance()).getInt(key)) ?? 0;
  }

  static Future setIntPreferences(String key, int value) async {
    (await SharedPreferences.getInstance()).setInt(key, value);
  }

  static Future clearAllPreferences() async {
    (await SharedPreferences.getInstance()).clear();
  }

  static Future<void> removeFromPreference(String key) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.remove(key);
  }

  static Future<dynamic> openActivity(context, object) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => object),
    );
  }

  static Future<dynamic> fadeOpenActivity(context, object) async {
    return await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return object;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<dynamic> fadeReplaceActivity(context, object) async {
    return await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return object;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static void replaceActivity(context, object) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => object),
    );
  }

  static void replaceNamedActivity(context, routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void openNamedActivity(context, routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void removeStackActivity(context, object) {
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => object), (r) => false);
  }

  static void closeActivity(context) {
    Navigator.pop(context);
  }

  static void returnDataCloseActivity(context, object) {
    Navigator.pop(context, object);
  }

  static String encodeJson(dynamic jsonData) {
    return json.encode(jsonData);
  }

  static dynamic decodeJson(String jsonString) {
    return json.decode(jsonString);
  }

  static Widget getLoadingAnimation(bool isLoading) {
    return PreferredSize(
        preferredSize: const Size(double.infinity, 6.0),
        child: isLoading
            ? LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.5)),
              )
            : Container());
  }
}
