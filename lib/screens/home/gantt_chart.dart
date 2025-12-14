import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/date_utils.dart' as utils;
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/event/event_detail.dart';
import 'package:gantt_mobile/screens/home/calendar_service_provider.dart';
import 'package:gantt_mobile/screens/home/home_screen.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/custom_alert_dialog.dart';
import 'package:gantt_mobile/widgets/components/edit_delete_bottom_sheet.dart';
import 'package:googleapis/calendar/v3.dart' as google_api;
import 'package:intl/intl.dart';
// import 'package:date_utils/date_utils.dart' as utils;
import 'package:provider/provider.dart';

class GanttChart extends StatefulWidget {
  final List<google_api.Event>? eventList;
  final List<google_api.CalendarListEntry> calendarEntry;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? calendarMode;

  const GanttChart({
    super.key,
    this.eventList,
    required this.calendarEntry,
    this.fromDate,
    this.toDate,
    required this.calendarMode,
  });

  @override
  State<GanttChart> createState() => _GanttChartState();
}

class _GanttChartState extends State<GanttChart> {
  int viewRangeToFitScreen =
      5; // In order to show the number of date columns in the view
  late int viewRange;

  // Predefined dark colors for calendars
  final List<Color> calendarColors = [
    const Color(0xFF1976D2), // Blue
    const Color(0xFF388E3C), // Green
    const Color(0xFFD32F2F), // Red
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFFF57C00), // Orange
    const Color(0xFF0097A7), // Cyan
    const Color(0xFFC2185B), // Pink
    const Color(0xFF5D4037), // Brown
    const Color(0xFF303F9F), // Indigo
    const Color(0xFF00796B), // Teal
    const Color(0xFFAFB42B), // Lime
    const Color(0xFF512DA8), // Deep Purple
    const Color(0xFFE64A19), // Deep Orange
    const Color(0xFF0288D1), // Light Blue
    const Color(0xFF689F38), // Light Green
  ];

  @override
  void initState() {
    // Generate the date range to show in the chart.
    viewRange =
        calculateNumberOfMonthsBetween(widget.fromDate!, widget.toDate!);
    super.initState();
  }

  // Get consistent color for a calendar based on its ID
  Color getCalendarColor(String calendarId) {
    final hash = calendarId.hashCode.abs();
    return calendarColors[hash % calendarColors.length];
  }

  // Gets the total numbers of months/days/hours between the start and end date of the event.
  int calculateNumberOfMonthsBetween(DateTime from, DateTime to) {
    if (widget.calendarMode == "monthly") {
      return (to.day - from.day) + 1;
    } else if (widget.calendarMode == "daily") {
      return 24; // 24 hours in a day
    } else {
      return to.month - from.month + 12 * (to.year - from.year) + 1;
    }
  }

  // Gets the padding length of the event item from the left end of the chart (with fractional hours for daily view)
  double calculateDistanceToLeftBorderPrecise(DateTime eventStartedAt) {
    if (widget.calendarMode == "daily") {
      // Convert to local time for display
      final localEventStart = eventStartedAt.toLocal();
      final localFromDate = widget.fromDate!.toLocal();

      if (localEventStart.compareTo(localFromDate) <= 0) {
        return 0.0;
      } else if (localEventStart.day != localFromDate.day) {
        return 0.0; // Event not on this day
      } else {
        // Calculate fractional hours (e.g., 10:30 = 10.5, 10:54 = 10.9)
        return localEventStart.hour + (localEventStart.minute / 60.0);
      }
    } else {
      if (eventStartedAt.compareTo(widget.fromDate!) <= 0) {
        return 0.0;
      } else {
        return (calculateNumberOfMonthsBetween(
                    widget.fromDate!, eventStartedAt) -
                1)
            .toDouble();
      }
    }
  }

  // Gets the padding length of the event item from the left end of the chart
  int calculateDistanceToLeftBorder(DateTime eventStartedAt) {
    return calculateDistanceToLeftBorderPrecise(eventStartedAt).floor();
  }

  // Calculate remaining width with precise fractional hours for daily view
  double calculateRemainingWidthPrecise(
      DateTime chartStartedAt, DateTime chartEndedAt) {
    if (widget.calendarMode == "daily") {
      // Convert to local time for display
      final localChartStart = chartStartedAt.toLocal();
      final localChartEnd = chartEndedAt.toLocal();
      final localFromDate = widget.fromDate!.toLocal();

      // For daily view, calculate hours
      if (localChartStart.day != localFromDate.day &&
          localChartEnd.day != localFromDate.day) {
        return 0.0; // Event not on this day
      }

      // Calculate fractional hours for start and end
      double startHourFractional = localChartStart.day == localFromDate.day
          ? localChartStart.hour + (localChartStart.minute / 60.0)
          : 0.0;
      double endHourFractional = localChartEnd.day == localFromDate.day
          ? localChartEnd.hour + (localChartEnd.minute / 60.0)
          : 23.0 + (59.0 / 60.0);

      // Calculate duration in fractional hours
      if (localChartStart.day == localFromDate.day &&
          localChartEnd.day == localFromDate.day) {
        // Both start and end on the same day
        double durationInHours =
            localChartEnd.difference(localChartStart).inMinutes / 60.0;
        return durationInHours > 0
            ? durationInHours
            : 0.1; // Minimum 0.1 hour (6 minutes) for visibility
      } else if (localChartStart.day == localFromDate.day) {
        return 24.0 - startHourFractional;
      } else if (localChartEnd.day == localFromDate.day) {
        return endHourFractional;
      }
      return 0.0;
    } else {
      int chartLength =
          calculateNumberOfMonthsBetween(chartStartedAt, chartEndedAt).toInt();
      if (chartStartedAt.compareTo(widget.fromDate!) >= 0 &&
          chartStartedAt.compareTo(widget.toDate!) <= 0) {
        if (chartLength <= viewRange) {
          return chartLength.toDouble();
        } else {
          return (viewRange -
                  calculateNumberOfMonthsBetween(
                      widget.fromDate!, chartStartedAt))
              .toDouble();
        }
      } else if (chartStartedAt.isBefore(widget.fromDate!) &&
          chartEndedAt.isBefore(widget.fromDate!)) {
        return 0.0;
      } else if (chartStartedAt.isBefore(widget.fromDate!) &&
          chartEndedAt.isBefore(widget.toDate!)) {
        return (chartLength -
                calculateNumberOfMonthsBetween(
                    chartStartedAt, widget.fromDate!))
            .toDouble();
      } else if (chartStartedAt.isBefore(widget.fromDate!) &&
          chartEndedAt.isAfter(widget.toDate!)) {
        return viewRange.toDouble();
      }
      return 0.0;
    }
  }

  // Integer version for backward compatibility
  int calculateRemainingWidth(DateTime chartStartedAt, DateTime chartEndedAt) {
    return calculateRemainingWidthPrecise(chartStartedAt, chartEndedAt).ceil();
  }

  /// Widget to show the charts bars that shows the date and event summary on the chart
  List<Widget> buildChartBars(
      List<google_api.Event> eventList,
      double chartViewWidth,
      BuildContext context,
      google_api.CalendarListEntry calendarEntry) {
    final List<Widget> chartBars = [];
    final calendarColor = getCalendarColor(calendarEntry.id!);

    for (int i = 0; i < eventList.length; i++) {
      final eventStart =
          eventList[i].start!.dateTime ?? eventList[i].start!.date!;
      final eventEnd = eventList[i].end?.dateTime ??
          eventList[i].end!.date!.subtract(const Duration(days: 1));

      var remainingWidth = calculateRemainingWidthPrecise(eventStart, eventEnd);

      if (remainingWidth > 0) {
        // Check if we're in daily mode and on current day to show time progress
        final now = DateTime.now();
        final localEventStart = eventStart.toLocal();
        final localEventEnd = eventEnd.toLocal();
        final isCurrentDay = widget.calendarMode == "daily" &&
            localEventStart.year == now.year &&
            localEventStart.month == now.month &&
            localEventStart.day == now.day;

        // Check if event has completely passed (for all calendar modes)
        final eventHasPassed = now.isAfter(localEventEnd);

        Widget eventBar;

        if (isCurrentDay &&
            now.isAfter(localEventStart) &&
            now.isBefore(localEventEnd)) {
          // Event is in progress - split into past (transparent) and future (opaque) portions
          final totalWidth =
              (remainingWidth * chartViewWidth) / viewRangeToFitScreen;
          final leftPosition =
              calculateDistanceToLeftBorderPrecise(eventStart) *
                  chartViewWidth /
                  viewRangeToFitScreen;

          // Calculate how much of the event has passed
          final currentHourFractional = now.hour + (now.minute / 60.0);
          final eventStartHourFractional =
              localEventStart.hour + (localEventStart.minute / 60.0);
          final eventDurationHours =
              localEventEnd.difference(localEventStart).inMinutes / 60.0;
          final elapsedHours = currentHourFractional - eventStartHourFractional;
          final progressRatio = elapsedHours / eventDurationHours;

          eventBar = Container(
            height: 25.0,
            width: totalWidth,
            margin: EdgeInsets.only(
              left: leftPosition,
              top: i == 0 ? 4.0 : 2.0,
              bottom: i == eventList.length - 1 ? 4.0 : 2.0,
            ),
            child: Stack(
              children: [
                // Past portion (semi-transparent)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: totalWidth * progressRatio,
                  child: Material(
                    color: calendarColor.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                    child: Container(),
                  ),
                ),
                // Future portion (opaque)
                Positioned(
                  left: totalWidth * progressRatio,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: calendarColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    child: Container(),
                  ),
                ),
                // Event text and tap handler on top
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5.0),
                      onTap: () {
                        debugPrint("Open Event Detail: ${eventList[i].id}");
                        Utilities.openActivity(
                            context,
                            EventDetail(
                                eventId: eventList[i].id!,
                                calendarId: calendarEntry.id!));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          eventList[i].summary ?? "-- No title --",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyle.extraSmallTextLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (eventHasPassed) {
          // Event has completely passed - make entire bar semi-transparent (for all calendar modes)
          eventBar = Container(
            height: 25.0,
            width: ((remainingWidth * chartViewWidth) / viewRangeToFitScreen),
            margin: EdgeInsets.only(
              left: calculateDistanceToLeftBorderPrecise(eventStart) *
                  chartViewWidth /
                  viewRangeToFitScreen,
              top: i == 0 ? 4.0 : 2.0,
              bottom: i == eventList.length - 1 ? 4.0 : 2.0,
            ),
            alignment: Alignment.center,
            child: Material(
              color: calendarColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(5.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(5.0),
                onTap: () {
                  debugPrint("Open Event Detail: ${eventList[i].id}");
                  Utilities.openActivity(
                      context,
                      EventDetail(
                          eventId: eventList[i].id!,
                          calendarId: calendarEntry.id!));
                },
                child: SizedBox(
                  width: ((remainingWidth * chartViewWidth) /
                      viewRangeToFitScreen),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      eventList[i].summary ?? "-- No title --",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.extraSmallTextLight,
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Event hasn't started yet or not in daily view - show normal opaque bar
          eventBar = Container(
            height: 25.0,
            width: ((remainingWidth * chartViewWidth) / viewRangeToFitScreen),
            margin: EdgeInsets.only(
              left: calculateDistanceToLeftBorderPrecise(eventStart) *
                  chartViewWidth /
                  viewRangeToFitScreen,
              top: i == 0 ? 4.0 : 2.0,
              bottom: i == eventList.length - 1 ? 4.0 : 2.0,
            ),
            alignment: Alignment.center,
            child: Material(
              color: calendarColor,
              borderRadius: BorderRadius.circular(5.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(5.0),
                onTap: () {
                  debugPrint("Open Event Detail: ${eventList[i].id}");
                  Utilities.openActivity(
                      context,
                      EventDetail(
                          eventId: eventList[i].id!,
                          calendarId: calendarEntry.id!));
                },
                child: SizedBox(
                  width: ((remainingWidth * chartViewWidth) /
                      viewRangeToFitScreen),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      eventList[i].summary ?? "-- No title --",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.extraSmallTextLight,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        chartBars.add(eventBar);
      }
    }

    return chartBars;
  }

  /// Header Widget to show the Calendar header
  Widget buildHeader(double chartViewWidth, Color color) {
    List<Widget> headerItems = [];
    DateTime tempDate = widget.fromDate!;
    headerItems.add(
      Container(
        width: (chartViewWidth / viewRangeToFitScreen) + 24,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColor.muted, width: 0.5),
            left: BorderSide(color: AppColor.muted, width: 0.5),
            right: BorderSide(color: AppColor.muted, width: 0.5),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('CALENDAR',
              textAlign: TextAlign.center,
              style: CustomTextStyle.hintExtraSmallBold),
        ),
      ),
    );

    for (int i = 0; i < viewRange; i++) {
      String headerText;
      if (widget.calendarMode == "daily") {
        // Show hours in 24-hour format (00:00 to 23:00)
        headerText = '${i.toString().padLeft(2, '0')}:00';
      } else if (widget.calendarMode == "monthly") {
        headerText = DateFormat.MMMd().format(tempDate);
      } else {
        headerText = DateFormat.yMMM().format(tempDate);
      }

      headerItems.add(
        Container(
          width: chartViewWidth / viewRangeToFitScreen,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColor.muted, width: 0.5),
              right: BorderSide(color: AppColor.muted, width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(headerText,
                textAlign: TextAlign.center,
                style: CustomTextStyle.extraSmallTextSecondaryBold),
          ),
        ),
      );

      if (widget.calendarMode == "monthly") {
        tempDate = tempDate.add(const Duration(days: 1));
      } else if (widget.calendarMode == "yearly") {
        tempDate = utils.DateUtils.nextMonth(tempDate);
      }
      // For daily mode, we don't need to increment tempDate as we're just showing hours
    }

    return Container(
      height: 30.0,
      color: color.withOpacity(0.8),
      child: Row(children: headerItems),
    );
  }

  /// Builds the grid on top of the chart bar
  Widget buildGrid(double chartViewWidth) {
    List<Widget> gridColumns = [];

    for (int i = 0; i <= viewRange; i++) {
      gridColumns.add(
        Container(
          decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(color: AppColor.muted, width: 0.5),
                bottom: BorderSide(color: AppColor.muted, width: 0.5)),
          ),
          width: i == 0
              ? (chartViewWidth / viewRangeToFitScreen) + 24
              : chartViewWidth / viewRangeToFitScreen,
        ),
      );
    }

    return Row(
      children: gridColumns,
    );
  }

  /// Widget to show all complete chart of the user that includes the calendar name as header title
  Widget buildChartForEachUser(
      List<google_api.Event> eventList,
      double chartViewWidth,
      google_api.CalendarListEntry calendarEntry,
      BuildContext context) {
    var chartBars =
        buildChartBars(eventList, chartViewWidth, context, calendarEntry);

    return SizedBox(
      height: chartBars.length < 5
          ? 5 * 29.0 + 38.0 + 11.0
          : chartBars.length * 29.0 + 38.0 + 15.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Stack(fit: StackFit.loose, children: <Widget>[
            buildGrid(chartViewWidth),
            buildHeader(chartViewWidth, AppColor.pale),
            Material(
              color: AppColor.transparent,
              child: InkWell(
                onTap: () {
                  bottomSheet(context, calendarEntry);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(2, 4, 2, 4),
                  child:
                      Icon(Icons.more_vert, color: AppColor.primary, size: 20),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 30.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: chartViewWidth / viewRangeToFitScreen + 24,
                            decoration: const BoxDecoration(
                              color: AppColor.primaryLight,
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColor.muted, width: 0.5),
                                left: BorderSide(
                                    color: AppColor.muted, width: 0.5),
                                right: BorderSide(
                                    color: AppColor.muted, width: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  calendarEntry.summary!,
                                  style: CustomTextStyle.smallTextBold,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: chartBars,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ]),
        ],
      ),
    );
  }

  /// Pass the events list and the calendars entry to the chart view
  List<Widget> buildChartContent(double chartViewWidth, BuildContext context) {
    List<Widget> chartContent = [];

    for (var calEntry in widget.calendarEntry) {
      List<google_api.Event> ganttEvents = [];
      ganttEvents = widget.eventList!
          .where((project) => project.organizer?.email == calEntry.id)
          .toList();

      // Filter events by date range for daily view
      if (widget.calendarMode == "daily") {
        final viewDate = widget.fromDate!.toLocal();
        ganttEvents = ganttEvents.where((event) {
          final eventStart =
              (event.start?.dateTime ?? event.start?.date)?.toLocal();
          final eventEnd = (event.end?.dateTime ?? event.end?.date)?.toLocal();

          if (eventStart == null || eventEnd == null) return false;

          // Check if event occurs on the viewing day
          final viewDayStart =
              DateTime(viewDate.year, viewDate.month, viewDate.day);
          final viewDayEnd =
              DateTime(viewDate.year, viewDate.month, viewDate.day, 23, 59, 59);

          // Event overlaps with the viewing day if:
          // - Event starts before or on the viewing day AND ends on or after the viewing day
          return eventStart
                  .isBefore(viewDayEnd.add(const Duration(seconds: 1))) &&
              eventEnd
                  .isAfter(viewDayStart.subtract(const Duration(seconds: 1)));
        }).toList();
      }

      chartContent.add(buildChartForEachUser(
          ganttEvents, chartViewWidth, calEntry, context));
    }

    return chartContent;
  }

  @override
  Widget build(BuildContext context) {
    var chartViewWidth = Utilities.screenWidth(context);
    var screenOrientation = Utilities.screenOrientation(context);

    // Adjust viewRangeToFitScreen based on calendar mode and orientation
    if (widget.calendarMode == "daily") {
      viewRangeToFitScreen =
          screenOrientation == Orientation.landscape ? 12 : 6;
    } else {
      viewRangeToFitScreen =
          screenOrientation == Orientation.landscape ? 10 : 5;
    }
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView(
        children: [
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: buildChartContent(chartViewWidth, context),
          ),
        ],
      ),
    );
  }

  Future bottomSheet(
      BuildContext context, google_api.CalendarListEntry calEntry) {
    final calendarProvider =
        Provider.of<CalendarServiceProvider>(context, listen: false);
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      builder: (BuildContext ctnx) {
        return EditDeleteBottomSheet(
          deleteFunction: () {
            Utilities.closeActivity(ctnx);

            showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return CustomAlertDialog(
                  leftButtonText: "YES",
                  rightButtonText: "NO",
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "Do you want to remove",
                            style: CustomTextStyle.headerTextLight
                                .copyWith(fontFamily: "nunitoSans")),
                        TextSpan(
                            text: " '${calEntry.summary}' ",
                            style: CustomTextStyle.headerTextSecondary
                                .copyWith(fontFamily: "nunitoSans")),
                        TextSpan(
                            text: "from the chart?",
                            style: CustomTextStyle.headerTextLight
                                .copyWith(fontFamily: "nunitoSans")),
                      ],
                    ),
                  ),
                  rightButtonFunction: () {
                    Utilities.closeActivity(ctx);
                  },
                  leftButtonFunction: () async {
                    List<String> encodedCalendarList = [];
                    Utilities.closeActivity(ctx);
                    calendarProvider.loader = true;
                    widget.calendarEntry.remove(calEntry);
                    if (widget.calendarEntry.isNotEmpty) {
                      for (google_api.CalendarListEntry calEntry
                          in widget.calendarEntry) {
                        encodedCalendarList.add(json.encode(
                            calEntry)); //Encode the calendars list to save in preference
                      }
                    }
                    saveCalendarInPref(encodedCalendarList).then((data) {
                      if (widget.calendarEntry.isEmpty) {
                        Utilities.fadeReplaceActivity(
                            context, const HomeScreen());
                      }
                    });

                    calendarProvider.loader = false;
                    showToast(
                        message: "'${calEntry.summary}' deleted successfully");
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
