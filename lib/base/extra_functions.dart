import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/auth/index_screen.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/custom_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? validateEmail({required BuildContext context, required String value, String fieldName = "Email"}) {
  value = value.trim();
  if (value.isEmpty) {
    return "$fieldName cannot be empty";
  }
  String regExpression = r"^(?=^.{6,255}$)([0-9a-zA-Z]+[-._+&amp;])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,85}$";
  RegExp regExp = RegExp(regExpression);
  if (!regExp.hasMatch(value)) {
    return "Enter a valid email";
  }
  return null;
}

String? validatePassword({required BuildContext context, required String value}) {
  if (value.isEmpty) {
    return "Password cannot be empty";
  } else if (!(value.length >= 8) && value.isNotEmpty) {
    return "Password should contains alteast 8 character";
  }
  return null;
}

String? validatePhone({required BuildContext context, required String value}) {
  if (value.isEmpty) {
    return "Phone cannot be empty";
  } else if (value.length < 9 || value.length > 10) {
    return "Phone should be contain either\n 9 or 10 characters";
  }
  return null;
}

String? validateEmptyField({required BuildContext context, required String value, required String fieldName}) {
  if (value.isEmpty) {
    return "$fieldName cannot be empty";
  }
  return null;
}

String getInitials(String name) {
  List<String> names = name.split(" ");
  String initials = "";
  int numWords = 1;

  if (numWords < names.length) {
    numWords = names.length;
  }
  for (var i = 0; i < numWords; i++) {
    initials += names[i][0];
  }
  return initials;
}

exitApp(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        leftButtonText: "YES",
        rightButtonText: "NO",
        title: const Text(
          "Do you want to exit the application?",
          style: CustomTextStyle.headerTextLight,
        ),
        rightButtonFunction: () {
          Utilities.closeActivity(context);
        },
        leftButtonFunction: () {
          SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
        },
      );
    },
  );
}

logout({
  required BuildContext context,
  required Function() leftButtonFunction,
  required Function() rightButtonFunction,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        leftButtonText: "YES",
        rightButtonText: "NO",
        title: const Text(
          "Do you want to sign out?",
          style: CustomTextStyle.headerTextLight,
        ),
        rightButtonFunction: rightButtonFunction,
        leftButtonFunction: leftButtonFunction,
      );
    },
  );
}

tokenExpire(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return CustomAlertDialog(
          title: const Text("Invalid authentication credentials!", style: CustomTextStyle.headerTextLight),
          body: const Text("Request had invalid authentication credentials. Please sign in and try again.",
              style: CustomTextStyle.bodyTextLight),
          leftButtonText: "OK",
          leftButtonFunction: () {
            Utilities.closeActivity(context);
            final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);
            authProvider.logout().then((value) {
              if (value != "exception") {
                clearUser();
                showToast(message: "Sign-out successful");
                Utilities.removeStackActivity(context, const IndexScreen());
              }
            });
          },
        );
      });
}

showToast(
    {required String message,
    Toast? toastLength,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    int timeInSecForIosWeb = 1,
    double? fontSize}) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: timeInSecForIosWeb,
      backgroundColor: backgroundColor ?? AppColor.primary.withOpacity(0.8),
      textColor: textColor ?? AppColor.primaryLight,
      fontSize: fontSize);
}

clearUser() async {
  SharedPreferences _sharedPreference = await SharedPreferences.getInstance();
  _sharedPreference.remove("authUser");
  _sharedPreference.remove("authUserHeader");
}

clearCalendarEvent() async {
  SharedPreferences _sharedPreference = await SharedPreferences.getInstance();
  _sharedPreference.remove("calendarList");
  _sharedPreference.remove("calendarEventList");
}

getAuth() async {
  SharedPreferences _sharedPreference = await SharedPreferences.getInstance();
  return {
    "Authorization": "${json.decode(_sharedPreference.getString("authUserHeader")!)["Authorization"]}",
    "X-Goog-AuthUser": "${json.decode(_sharedPreference.getString("authUserHeader")!)["X-Goog-AuthUser"]}",
  };
}

saveCalendarInPref(List<String> calendarList) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  _sharedPreferences.setStringList("calendarList", calendarList);
}

List<TextSpan> highlightOccurrences({required String source, required String query, Color textColor = Colors.black}) {
  if (query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
    return [TextSpan(text: source)];
  }
  final matches = query.toLowerCase().allMatches(source.toLowerCase());

  int lastMatchEnd = 0;

  final List<TextSpan> children = [];
  for (var i = 0; i < matches.length; i++) {
    final match = matches.elementAt(i);

    if (match.start != lastMatchEnd) {
      children.add(TextSpan(
        text: source.substring(lastMatchEnd, match.start),
      ));
    }

    children.add(TextSpan(
      text: source.substring(match.start, match.end),
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
    ));

    if (i == matches.length - 1 && match.end != source.length) {
      children.add(TextSpan(
        text: source.substring(match.end, source.length),
      ));
    }

    lastMatchEnd = match.end;
  }
  return children;
}
