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

  @override
  void initState() {
    // Generate the date range to show in the chart.
    viewRange =
        calculateNumberOfMonthsBetween(widget.fromDate!, widget.toDate!);
    super.initState();
  }

  // Gets the total numbers of months between the start and end date of the event.
  int calculateNumberOfMonthsBetween(DateTime from, DateTime to) {
    if (widget.calendarMode == "monthly") {
      return (to.day - from.day) + 1;
    }
    // else if (widget.calendarMode == "day") {
    //   return to.difference(from).inHours + 1;
    // }
    else {
      return to.month - from.month + 12 * (to.year - from.year) + 1;
    }
  }

  // Gets the padding length of the event item from the left end of the chart
  int calculateDistanceToLeftBorder(DateTime eventStartedAt) {
    if (eventStartedAt.compareTo(widget.fromDate!) <= 0) {
      return 0;
    } else {
      return calculateNumberOfMonthsBetween(widget.fromDate!, eventStartedAt) -
          1;
    }
  }

  int calculateRemainingWidth(DateTime chartStartedAt, DateTime chartEndedAt) {
    int chartLength =
        calculateNumberOfMonthsBetween(chartStartedAt, chartEndedAt);
    if (chartStartedAt.compareTo(widget.fromDate!) >= 0 &&
        chartStartedAt.compareTo(widget.toDate!) <= 0) {
      if (chartLength <= viewRange) {
        return chartLength;
      } else {
        return viewRange -
            calculateNumberOfMonthsBetween(widget.fromDate!, chartStartedAt);
      }
    } else if (chartStartedAt.isBefore(widget.fromDate!) &&
        chartEndedAt.isBefore(widget.fromDate!)) {
      return 0;
    } else if (chartStartedAt.isBefore(widget.fromDate!) &&
        chartEndedAt.isBefore(widget.toDate!)) {
      return chartLength -
          calculateNumberOfMonthsBetween(chartStartedAt, widget.fromDate!);
    } else if (chartStartedAt.isBefore(widget.fromDate!) &&
        chartEndedAt.isAfter(widget.toDate!)) {
      return viewRange;
    }
    return 0;
  }

  /// Widget to show the charts bars that shows the date and event summary on the chart
  List<Widget> buildChartBars(
      List<google_api.Event> eventList,
      double chartViewWidth,
      BuildContext context,
      google_api.CalendarListEntry calendarEntry) {
    final List<Widget> chartBars = [];

    for (int i = 0; i < eventList.length; i++) {
      var remainingWidth = calculateRemainingWidth(
          eventList[i].start!.dateTime ?? eventList[i].start!.date!,
          eventList[i].end?.dateTime ??
              eventList[i].end!.date!.subtract(const Duration(days: 1)));

      if (remainingWidth > 0) {
        chartBars.add(
          Container(
            height: 25.0,
            width: ((remainingWidth * chartViewWidth) / viewRangeToFitScreen),
            margin: EdgeInsets.only(
              left: calculateDistanceToLeftBorder(
                      eventList[i].start?.dateTime ??
                          eventList[i].start!.date!) *
                  chartViewWidth /
                  viewRangeToFitScreen,
              top: i == 0 ? 4.0 : 2.0,
              bottom: i == eventList.length - 1 ? 4.0 : 2.0,
            ),
            alignment: Alignment.center,
            child: Material(
              color: AppColor.primary,
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
          ),
        );
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
            child: Text(
                widget.calendarMode == "monthly"
                    ? DateFormat.MMMd().format(tempDate)
                    : DateFormat.yMMM().format(tempDate),
                textAlign: TextAlign.center,
                style: CustomTextStyle.extraSmallTextSecondaryBold),
          ),
        ),
      );
      widget.calendarMode == "monthly"
          ? tempDate = tempDate.add(const Duration(days: 1))
          : tempDate = utils.DateUtils.nextMonth(tempDate);
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
      chartContent.add(buildChartForEachUser(
          ganttEvents, chartViewWidth, calEntry, context));
    }

    return chartContent;
  }

  @override
  Widget build(BuildContext context) {
    var chartViewWidth = Utilities.screenWidth(context);
    var screenOrientation = Utilities.screenOrientation(context);
    screenOrientation == Orientation.landscape
        ? viewRangeToFitScreen = 10
        : viewRangeToFitScreen = 5;
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
