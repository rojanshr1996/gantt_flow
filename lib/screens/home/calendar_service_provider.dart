import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/screens/auth/google_http_client.dart';
import 'package:googleapis/calendar/v3.dart' as google_api;
import 'package:shared_preferences/shared_preferences.dart';

class CalendarServiceProvider extends ChangeNotifier {
  bool _calendarWaiting = true;
  bool _eventWaiting = true;
  bool _chartWaiting = false;
  bool _loader = false;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  bool get calendarWaiting => _calendarWaiting;
  set calendarWaiting(bool data) {
    _calendarWaiting = data;
    notifyListeners();
  }

  bool get loader => _loader;
  set loader(bool data) {
    _loader = data;
    notifyListeners();
  }

  bool get eventWaiting => _eventWaiting;
  set eventWaiting(bool data) {
    _eventWaiting = data;
    notifyListeners();
  }

  bool get chartWaiting => _chartWaiting;
  set chartWaiting(bool data) {
    _chartWaiting = data;
    notifyListeners();
  }

  /// Fetch the google calendar List
  Future<dynamic> getCalendarList(BuildContext context) async {
    if (currentUser == null) {
      debugPrint("User not logged in");
      return "exception";
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("authUserHeader") != null) {
      try {
        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar = google_api.CalendarApi(authenticateClient);
        final result = await calendar.calendarList.list();
        debugPrint("VAL________${result.items}");
        notifyListeners();
        return result.items;
      } on google_api.DetailedApiRequestError catch (e) {
        debugPrint("ERROR: $e");
        if (e.status == 401) {
          tokenExpire(context);
        } else {
          Future.delayed((const Duration(milliseconds: 1500)), () {
            showToast(message: "${e.message}", timeInSecForIosWeb: 2);
          });
        }
        return "exception";
      } catch (e) {
        debugPrint("ERROR: $e");
        showToast(message: "Request failed. Please try again.", timeInSecForIosWeb: 2);
        return "exception";
      }
    }
    return null;
  }

  /// Api to fetch the event list using the calendar entry ID
  Future<dynamic> getEventList(BuildContext context, google_api.CalendarListEntry calendarEntry) async {
    if (currentUser == null) {
      debugPrint("User not logged in");
      return "exception";
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    debugPrint("CALENDAR ID: ${calendarEntry.id}");

    if (sharedPreferences.getString("authUserHeader") != null) {
      try {
        // Get the authentication headers from the shared preferences
        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar = google_api.CalendarApi(authenticateClient);
        final result = await calendar.events.list(calendarEntry.id!);
        // notifyListeners();
        return result;
      } on google_api.DetailedApiRequestError catch (e) {
        debugPrint("Event List ERROR: $e");
        if (e.status == 401) {
          /// Sign user out when token expires
          tokenExpire(context);
        } else {
          Future.delayed((const Duration(milliseconds: 1500)), () {
            showToast(message: "${e.message}", timeInSecForIosWeb: 2);
          });
        }
        return "exception";
      } catch (e) {
        debugPrint("ERROR: $e");
        showToast(message: "Error encountered while fetching events. Please try again.", timeInSecForIosWeb: 2);
        return "exception";
      }
    }
    return null;
  }

  /// Delete the calendar entry from the App.
  Future<dynamic> deleteCalendar({required BuildContext context, required String calendarId}) async {
    if (currentUser == null) {
      debugPrint("User not logged in");
      return "exception";
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("authUserHeader") != null) {
      try {
        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar = google_api.CalendarApi(authenticateClient);
        try {
          await calendar.calendarList.delete(calendarId);
          return null;
        } on google_api.DetailedApiRequestError catch (e) {
          debugPrint("ERROR: $e");
          if (e.status == 401) {
            tokenExpire(context);
          } else {
            showToast(message: "${e.message}", timeInSecForIosWeb: 2);
          }
          return "exception";
        } catch (e) {
          return "exception";
        }
      } on google_api.DetailedApiRequestError catch (e) {
        debugPrint("ERROR: $e");
        if (e.status == 401) {
          tokenExpire(context);
        } else {
          Future.delayed((const Duration(milliseconds: 1500)), () {
            showToast(message: "${e.message}", timeInSecForIosWeb: 2);
          });
        }
        return "exception";
      } catch (e) {
        debugPrint("ERROR: $e");
        return "exception";
      }
    }
    return null;
  }
}
