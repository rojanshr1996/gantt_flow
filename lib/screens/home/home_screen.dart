import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/main.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/event/create_event.dart';
import 'package:gantt_mobile/screens/event/event_service_provider.dart';
import 'package:gantt_mobile/screens/home/add_calendar_dialog.dart';
import 'package:gantt_mobile/screens/home/calendar_service_provider.dart';
import 'package:gantt_mobile/screens/home/gantt_chart.dart';
import 'package:gantt_mobile/screens/home/generated_pdf.dart';
import 'package:gantt_mobile/screens/settings/settings.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/button_widget.dart';
import 'package:gantt_mobile/widgets/components/custom_circular_loader.dart';
import 'package:gantt_mobile/widgets/components/no_data_widget.dart';
import 'package:gantt_mobile/widgets/components/simple_circular_loader.dart';
import 'package:gantt_mobile/widgets/homeWidgets/calendar_bar.dart';
import 'package:googleapis/calendar/v3.dart' as google_api;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, RouteAware {
  String layoutValue = "MONTH";
  List<google_api.CalendarListEntry> calendars = [];
  List<String> encodedCalendarList = [];

  List<String> encodedEventList = [];
  List<google_api.Events> eventsList = [];
  List<google_api.Event> eventList = [];

  late AnimationController animationController;

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String showDateHeader = "";

  List<google_api.Event> events = [];

  List<String> calendarIdList = [];

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    initializeDateFormatting();

    animationController = AnimationController(duration: const Duration(microseconds: 2000), vsync: this);
    animationController.forward();
    // Get the layout value in order to determine if it is "MONTH" or "YEAR".
    // Defaults to [MONTH]
    getLayoutValue().then((data) {
      if (data == null) {
        saveLayoutValue(layoutValue);
      } else {
        layoutValue = data;
      }
      updateGanttChartDate();
      reloadCalendarList(init: true);
    });
  }

  // Update the from-date and to-date to show in the chart after the layout value is determined
  void updateGanttChartDate() {
    if (layoutValue == "MONTH") {
      fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
      toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      showDateHeader = DateFormat.yMMMM().format(fromDate);
      debugPrint("Monthly from date: $fromDate ----- Monthly to date: $toDate");
    } else if (layoutValue == "DAY") {
      // fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00);
      // toDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 00, 00);
      // showDateHeader = DateFormat.yMMMM().format(fromDate);
      // debugPrint(showDateHeader);
    } else {
      fromDate = DateTime(DateTime.now().year, 1, 1);
      toDate = DateTime(DateTime.now().year + 1, 1, 0);
      showDateHeader = DateFormat.y().format(fromDate);
      debugPrint("Yearly from date: $fromDate ----- Yearly to date: $toDate");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when the top route has been popped off, and the current route shows up.
  @override
  void didPopNext() {
    debugPrint('didPopNext route');
    final eventProvider = Provider.of<EventServiceProvider>(context, listen: false);
    if (eventProvider.eventDeleted || eventProvider.eventEdited) {
      debugPrint("Reload the home screen");
      reloadCalendarList();
    }
  }

  Future<void> reloadCalendarList({bool init = false}) async {
    final calendarProvider = Provider.of<CalendarServiceProvider>(context, listen: false);
    final eventProvider = Provider.of<EventServiceProvider>(context, listen: false);

    eventProvider.setEventEdited(false);
    eventProvider.setEventDeleted(false);

    // inis is [true] when called from the initState
    // Fetch the calendar list from the shared preferences in order to further fetch the event list
    if (init) {
      calendars.clear();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      encodedCalendarList = sharedPreferences.getStringList("calendarList") ?? [];
      if (encodedCalendarList.isNotEmpty) {
        for (String value in encodedCalendarList) {
          google_api.CalendarListEntry item = google_api.CalendarListEntry.fromJson(json.decode(value));
          if (calendars.every((data) => data.id != item.id)) {
            calendars.add(item); //Add calendar to the list to show in the chart
          }
        }

        fetchEvents(context, calendars);
      } else {
        debugPrint("Loop Stops ----> Reload Calendar");

        calendarProvider.eventWaiting = false;
        calendarProvider.chartWaiting = false;
      }
    } else {
      fetchEvents(context, calendars);
    }
  }

  void fetchEvents(BuildContext context, List<google_api.CalendarListEntry> calendars) {
    final calendarProvider = Provider.of<CalendarServiceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);

    debugPrint("$calendars");
    encodedEventList.clear();

    // Do silent login initially in order to get the accesstoken and fetch the event list
    authProvider.refreshToken().then((data) async {
      if (data != "exception") {
        if (calendars.isNotEmpty) {
          eventList.clear();
          events.clear();

          Future.forEach(calendars, (google_api.CalendarListEntry calEntry) async {
            try {
              // Fetch the event list for each calendar using loop
              final event = await calendarProvider.getEventList(context, calEntry);

              if (event != "exception" && event != null) {
                final google_api.Events eventData = event as google_api.Events;
                debugPrint("${eventData.items?.length}");

                eventData.items?.map((event) {
                  if (events.every((element) => element.id != event.id)) {
                    events.add(event);
                  }
                }).toList();

                debugPrint("${events.length}");

                encodedEventList.add(json.encode(eventList)); //Encode the calendar events to save in preference
                saveCalendarEventsInPref(encodedEventList);
              }
            } catch (e) {
              debugPrint("$e");
            }
          }).then((value) {
            calendarProvider.eventWaiting = false;
            calendarProvider.chartWaiting = false;
          });
        }
      } else {
        // Navigate to login screen if token expires
        tokenExpire(context);
      }
    });
  }

  // Dialog in order to add new calendar to the chart
  void showCalendarDialog() {
    final calendarProvider = Provider.of<CalendarServiceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);

    // Show the select calendar dialog when Add Calendar is tapped or "+" button is tapped on the top bar
    showDialog(builder: (BuildContext ctx) => const AddCalendarDialog(), context: context).then((calendar) async {
      if (calendar != null) {
        calendarProvider.loader = true;
        authProvider.refreshToken().then((data) async {
          if (data != "exception") {
            if (calendars.every((element) => element.id != calendar.id)) {
              // Fetch the event list from that calendar and add it to the existing event list and save to the preference
              final dynamic eventListResult = await calendarProvider.getEventList(context, calendar);
              final google_api.Events eventList = eventListResult as google_api.Events;

              debugPrint("${eventList.items?.length}");
              eventList.items?.map((event) {
                if (events.every((element) => element.id != event.id)) {
                  debugPrint("THIS IS EVENT LIST: ${event.summary}");
                  events.add(event);
                }
              }).toList();
              debugPrint("${events.length}");

              setState(() {
                encodedEventList.add(json.encode(eventList)); //Encode the calendar events to save in preference

                calendars.add(calendar);
                encodedCalendarList.add(json.encode(calendar)); //Encode the calendars list to save in preference

                saveCalendarInPref(encodedCalendarList);
                saveCalendarEventsInPref(encodedEventList);
              });
              calendarProvider.loader = false;
              showToast(message: "'${calendar.summary}' added successfully");
            } else {
              calendarProvider.loader = false;
              showToast(message: "Selected calendar already exists");
            }
          } else {
            tokenExpire(context);
          }
        });
      }
    });
  }

  Future<void> saveCalendarEventsInPref(List<String> eventList) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList("calendarEventList", eventList);
  }

  Future<void> saveLayoutValue(String layoutValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("layoutValue", layoutValue);
  }

  Future<String?> getLayoutValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("layoutValue");
  }

  // Refresh list on swipe down from the screen
  Future<void> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    final calendarProvider = Provider.of<CalendarServiceProvider>(context, listen: false);
    calendarProvider.chartWaiting = true;
    updateGanttChartDate();
    reloadCalendarList();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => exitApp(context),
      child: Scaffold(
          backgroundColor: AppColor.light,
          appBar: AppBar(
            title: const AppBarTitle(title: "Home"),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: AppColor.light,
                ),
                onPressed: () => Utilities.openActivity(context, const Settings()),
              )
            ],
          ),
          body: Consumer<CalendarServiceProvider>(
            builder: (context, calendarProvider, _) {
              return Stack(
                children: [
                  calendarProvider.eventWaiting
                      ? const Center(child: SimpleCircularLoader())
                      : encodedCalendarList.isNotEmpty
                          ? calendars.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Center(
                                    child: NoDataWidget(title: "No data"),
                                  ),
                                )
                              : Column(
                                  children: [
                                    CalendarBar(
                                      onAddCalendar: () => showCalendarDialog(),
                                      onAddEvent: () =>
                                          Utilities.openActivity(context, const CreateEvent()).then((data) {
                                        debugPrint("$data");
                                        if (data != null) {
                                          reloadCalendarList();
                                        }
                                      }),
                                      onDownloadAsPDF: () {
                                        Utilities.openActivity(
                                            context,
                                            GeneratedPdf(
                                              calendarMode: layoutValue == "YEAR" ? "yearly" : "monthly",
                                              fromDate: fromDate,
                                              toDate: toDate,
                                              calendarEntry: calendars,
                                              eventList: events,
                                            ));
                                      },
                                      dropdownValue: layoutValue,
                                      onChangeLayout: (String value) {
                                        setState(() {
                                          if (layoutValue != value) {
                                            layoutValue = value;
                                            debugPrint(layoutValue);
                                            saveLayoutValue(layoutValue);

                                            final calendarProvider =
                                                Provider.of<CalendarServiceProvider>(context, listen: false);
                                            calendarProvider.chartWaiting = true;
                                            updateGanttChartDate();
                                            reloadCalendarList();
                                          }
                                        });
                                      },
                                    ),
                                    calendarProvider.chartWaiting
                                        ? const SizedBox()
                                        : Container(
                                            color: AppColor.primary,
                                            child: ListTile(
                                              title: Text(
                                                layoutValue == "MONTH"
                                                    ? DateFormat.yMMMM().format(fromDate)
                                                    : layoutValue == "YEAR"
                                                        ? DateFormat.y().format(fromDate)
                                                        : DateFormat.MMMd().format(fromDate),
                                                textAlign: TextAlign.center,
                                                style: CustomTextStyle.bodyTextLightBold,
                                              ),
                                              leading: headerIcon(
                                                  onPressed: () {
                                                    if (layoutValue == "MONTH") {
                                                      fromDate = DateTime(fromDate.year, fromDate.month - 1, 1);
                                                      toDate = DateTime(toDate.year, toDate.month, 0);
                                                      showDateHeader = DateFormat.yMMMM().format(fromDate);
                                                      debugPrint("Changed Date back (monthly): $fromDate -> $toDate");
                                                      setState(() {});
                                                    } else if (layoutValue == "DAY") {
                                                      // fromDate = fromDate.subtract(const Duration(days: 1));
                                                      // toDate = toDate.subtract(const Duration(days: 1));
                                                      // showDateHeader = DateFormat.yMMMM().format(fromDate);
                                                      // debugPrint("Changed Date back (daily): $fromDate -> $toDate");
                                                      // setState(() {});
                                                    } else {
                                                      fromDate = DateTime(fromDate.year - 1, 1, 1);
                                                      toDate = DateTime(toDate.year, 1, 0);
                                                      showDateHeader = DateFormat.y().format(fromDate);
                                                      debugPrint("Changed Date back (yearly): $fromDate -> $toDate");
                                                      setState(() {});
                                                    }
                                                  },
                                                  icon: Icons.arrow_back_ios),
                                              trailing: headerIcon(
                                                  onPressed: () {
                                                    if (layoutValue == "MONTH") {
                                                      fromDate = DateTime(fromDate.year, fromDate.month + 1, 1);
                                                      toDate = DateTime(toDate.year, toDate.month + 2, 0);
                                                      showDateHeader = DateFormat.yMMMM().format(fromDate);
                                                      debugPrint(
                                                          "Changed Date forward (monthly): $fromDate -> $toDate");

                                                      setState(() {});
                                                    } else if (layoutValue == "DAY") {
                                                      // fromDate = fromDate.add(const Duration(days: 1));
                                                      // toDate = toDate.add(const Duration(days: 1));
                                                      // showDateHeader = DateFormat.yMMMM().format(fromDate);
                                                      // debugPrint("Changed Date back (monthly): $fromDate -> $toDate");
                                                      // setState(() {});
                                                    } else {
                                                      fromDate = DateTime(fromDate.year + 1, 1, 1);
                                                      toDate = DateTime(toDate.year + 2, 1, 0);
                                                      showDateHeader = DateFormat.y().format(fromDate);
                                                      debugPrint("Changed Date forward (yearly): $fromDate -> $toDate");
                                                      setState(() {});
                                                    }
                                                  },
                                                  icon: Icons.arrow_forward_ios),
                                            ),
                                          ),
                                    Expanded(
                                      child: calendarProvider.chartWaiting
                                          ? const Center(child: SimpleCircularLoader())
                                          : RefreshIndicator(
                                              key: refreshKey,
                                              onRefresh: refreshList,
                                              backgroundColor: AppColor.primary,
                                              color: AppColor.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: GanttChart(
                                                    calendarMode: layoutValue == "YEAR" ? "yearly" : "monthly",
                                                    fromDate: fromDate,
                                                    toDate: toDate,
                                                    calendarEntry: calendars,
                                                    eventList: events,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    )
                                  ],
                                )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: ButtonWidget(
                                    buttonWidth: Utilities.screenWidth(context) * 0.45,
                                    onTap: () => showCalendarDialog(),
                                    title: "ADD CALENDAR",
                                    prefixIcon: const Icon(Icons.add, color: AppColor.light),
                                    textStyle: CustomTextStyle.bodyTextLight,
                                  ),
                                ),
                              ],
                            ),
                  calendarProvider.loader ? const CustomCircularLoader() : Container(),
                ],
              );
            },
          )),
    );
  }

  IconButton headerIcon({Function()? onPressed, required IconData icon}) {
    return IconButton(onPressed: onPressed, icon: Icon(icon, color: AppColor.light, size: 20));
  }
}
