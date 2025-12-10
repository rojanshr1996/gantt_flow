import 'package:flutter/cupertino.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/screens/auth/google_http_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart' as google_api;
import 'package:googleapis/drive/v3.dart' as gdrive;

class EventServiceProvider extends ChangeNotifier {
  bool _eventDetailWaiting = true;
  bool _eventDeleted = false;
  bool _eventEdited = false;

  List<google_api.Event> _eventList = [];

  List<gdrive.File> _selectedFileList = [];

  String _nextPageToken = "";

  String get nextPageToken => _nextPageToken;
  setNextPageToken(String data) {
    _nextPageToken = data;
  }

  bool get eventDeleted => _eventDeleted;
  setEventDeleted(bool data) {
    _eventDeleted = data;
  }

  bool get eventEdited => _eventEdited;
  setEventEdited(bool data) {
    _eventEdited = data;
  }

  bool get eventDetailWaiting => _eventDetailWaiting;
  set eventDetailWaiting(bool data) {
    _eventDetailWaiting = data;
    notifyListeners();
  }

  List<google_api.Event> get eventList => _eventList;
  set eventList(List<google_api.Event> listData) {
    _eventList = listData;
    notifyListeners();
  }

  List<gdrive.File> get selectedFileList => _selectedFileList;
  set selectedFileList(List<gdrive.File> listData) {
    _selectedFileList = listData;
    notifyListeners();
  }

  clearFileList() {
    _selectedFileList = [];
  }

  /// Fetch the event detail using the calendarID and eventId.
  getEventDetail(
      {required BuildContext context,
      required String calendarId,
      required String eventId}) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    if (_sharedPreferences.getString("authUserHeader") != null) {
      try {
        late google_api.Event eventData;
        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar =
            google_api.CalendarApi(authenticateClient);
        final google_api.Events events = await calendar.events.list(
            calendarId); // Pass the calendarID in order to get the events list in that particular calendar
        for (google_api.Event event in events.items!) {
          if (event.id == eventId) {
            debugPrint("$calendarId ===> ${event.id} ===> ${event.etag}");
            eventData = event;
            break;
          }
        }
        return eventData;
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
      } on google_api.ApiRequestError catch (e) {
        debugPrint("ERROR: $e");
        Future.delayed((const Duration(milliseconds: 1500)), () {
          showToast(message: "${e.message}", timeInSecForIosWeb: 2);
        });
        return "exception";
      } catch (e) {
        debugPrint("ERROR: $e");
        return "exception";
      }
    }
  }

  /// Insert new event to the calendar.
  /// The event will be addedd to the google calendar also
  insertEvent({
    required BuildContext context,
    String? calendarId,
    String? title,
    String? startTime,
    String? endTime,
    String? description,
    String? location,
    bool allDayEvent = false,
    List<gdrive.File> attachments = const [],
    List<google_api.EventAttendee>? attendees = const [],
  }) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    debugPrint("THIS IS THE ATTACHMENT LIST: $attachments");
    if (_sharedPreferences.getString("authUserHeader") != null) {
      try {
        late google_api.Event? eventData;

        google_api.Event event = google_api.Event();

        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar =
            google_api.CalendarApi(authenticateClient);

        if (title != null) {
          event.summary = title; //Event title
        }

        if (allDayEvent) {
          event.start = google_api.EventDateTime(
              date: DateTime.parse(startTime!),
              timeZone: "GMT+05:45"); //Event Start dateTime

          event.end = google_api.EventDateTime(
              date: DateTime.parse(endTime!).add(const Duration(days: 1)),
              timeZone: "GMT+05:45"); //Event End dateTime
        } else {
          event.start = google_api.EventDateTime(
              dateTime: DateTime.parse(startTime!),
              timeZone: "GMT+05:45"); //Event Start dateTime

          event.end = google_api.EventDateTime(
              dateTime: DateTime.parse(endTime!),
              timeZone: "GMT+05:45"); //Event End dateTime
        }

        if (description != null) {
          event.description = description;
        }
        if (location != null) {
          event.location = location;
        }

        if (attendees!.isNotEmpty) {
          debugPrint("This is the attendees: $attendees");
          event.attendees = attendees;
        }

        List<google_api.EventAttachment> fileList = [];
        if (attachments.isNotEmpty) {
          for (gdrive.File file in attachments) {
            google_api.EventAttachment fileData = google_api.EventAttachment(
                fileId: file.id,
                fileUrl: file.webViewLink,
                iconLink: file.iconLink,
                mimeType: file.mimeType,
                title: file.name);

            fileList.add(fileData);
          }
          debugPrint("EventAttachment list: ${fileList.length}");

          event.attachments = fileList;
        }

        debugPrint("${event.attachments?.first.fileId}");

        try {
          eventData = await calendar.events.insert(event, calendarId!,
              sendUpdates: "all", supportsAttachments: true);
          return eventData;
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
  }

  /// Edit the event based on the eventID and calendar ID.
  /// setting [sendUpdates] to true will provide notification to the users on their respective Gmail ID
  updateEvent({
    required BuildContext context,
    String? calendarId,
    String? eventId,
    String? title,
    String? startTime,
    String? endTime,
    String? description,
    String? location,
    List<google_api.EventAttendee>? attendees = const [],
    List<google_api.EventAttachment> eventAttachment = const [],
    List<gdrive.File> attachments = const [],
    bool allDayEvent = false,
  }) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    if (_sharedPreferences.getString("authUserHeader") != null) {
      try {
        late google_api.Event? eventData;

        google_api.Event event = google_api.Event();

        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar =
            google_api.CalendarApi(authenticateClient);

        if (title != null) {
          event.summary = title; //Event title
        }

        if (allDayEvent) {
          event.start = google_api.EventDateTime(
              date: DateTime.parse(startTime!),
              timeZone: "GMT+05:45"); //Event Start dateTime

          event.end = google_api.EventDateTime(
              date: DateTime.parse(endTime!).add(const Duration(days: 1)),
              timeZone: "GMT+05:45"); //Event End dateTime
        } else {
          event.start = google_api.EventDateTime(
              dateTime: DateTime.parse(startTime!),
              timeZone: "GMT+05:45"); //Event Start dateTime

          event.end = google_api.EventDateTime(
              dateTime: DateTime.parse(endTime!),
              timeZone: "GMT+05:45"); //Event End dateTime
        }

        if (description != null) {
          event.description = description;
        }
        if (attendees!.isNotEmpty) {
          debugPrint("This is the attendees: $attendees");
          event.attendees = attendees;
        }
        if (location != null) {
          event.location = location;
        }
        List<google_api.EventAttachment> fileList = [];

        if (eventAttachment.isNotEmpty) {
          fileList = eventAttachment;
          event.attachments = fileList;
        }

        if (attachments.isNotEmpty) {
          for (gdrive.File file in attachments) {
            google_api.EventAttachment fileData = google_api.EventAttachment(
                fileId: file.id,
                fileUrl: file.webViewLink,
                iconLink: file.iconLink,
                mimeType: file.mimeType,
                title: file.name);

            fileList.add(fileData);
          }
          debugPrint("EventAttachment list: ${fileList.length}");

          event.attachments = fileList;
        }

        debugPrint("${event.attachments?.first.fileId}");

        debugPrint("$calendarId ===> $eventId");
        try {
          eventData = await calendar.events.update(event, calendarId!, eventId!,
              sendUpdates: "all", supportsAttachments: true);
          debugPrint("THIS IS EVENT DATA EDITED: $eventData");
          return eventData;
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
  }

  Future listGoogleDriveFiles(BuildContext context,
      {String pageToken = ""}) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final eventProvider =
        Provider.of<EventServiceProvider>(context, listen: false);
    debugPrint("THIS IS THE PAGE TOKEN: $pageToken");
    if (_sharedPreferences.getString("authUserHeader") != null) {
      try {
        final authenticateClient = GoogleHttpClient(await getAuth());

        gdrive.DriveApi drive = gdrive.DriveApi(authenticateClient);
        gdrive.FileList fileList =
            await drive.files.list(pageToken: pageToken, $fields: "*");

        eventProvider.setNextPageToken(fileList.nextPageToken ?? "");
        return fileList;
      } on google_api.DetailedApiRequestError catch (e) {
        debugPrint("ERROR (${e.status}): $e");
        if (e.status == 401) {
          tokenExpire(context);
        } else {
          Future.delayed((const Duration(seconds: 1)), () {
            showToast(message: "${e.message}", timeInSecForIosWeb: 2);
          });
        }
        return "exception";
      } catch (e) {
        debugPrint("ERROR: $e");
        return "exception";
      }
    }
  }

  deleteEvent(
      {required BuildContext context,
      required String calendarId,
      required String eventId}) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    if (_sharedPreferences.getString("authUserHeader") != null) {
      try {
        final authenticateClient = GoogleHttpClient(await getAuth());
        final google_api.CalendarApi calendar =
            google_api.CalendarApi(authenticateClient);

        try {
          // await calendar.events.delete(calendarId, eventId);
          return await calendar.events
              .delete(calendarId, eventId, sendUpdates: "all");
        } on google_api.DetailedApiRequestError catch (e) {
          debugPrint("ERROR: $e");
          if (e.status == 401) {
            tokenExpire(context);
          } else {
            showToast(message: "${e.message}", timeInSecForIosWeb: 2);
          }
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
      } catch (e) {
        debugPrint("ERROR: $e");
      }
    }
  }
}
