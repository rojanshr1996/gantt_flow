import 'dart:typed_data';

import 'package:gantt_mobile/base/date_utils.dart' as utils;
import 'package:googleapis/calendar/v3.dart' as google_api;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Gantt Chart UI to show in the PDF
/// Widgets package is taken from the pdf package instead of the 'Material' library
class PdfGanttChart extends pw.StatelessWidget {
  List<google_api.Event>? eventList;
  List<google_api.CalendarListEntry> calendarEntry;
  DateTime? fromDate;
  DateTime? toDate;
  String? calendarMode;

  late int viewRange;
  int viewRangeToFitScreen = 12;

  // Predefined dark colors for calendars (matching gantt_chart.dart)
  final List<String> calendarColorHexes = [
    "#1976D2", // Blue
    "#388E3C", // Green
    "#D32F2F", // Red
    "#7B1FA2", // Purple
    "#F57C00", // Orange
    "#0097A7", // Cyan
    "#C2185B", // Pink
    "#5D4037", // Brown
    "#303F9F", // Indigo
    "#00796B", // Teal
    "#AFB42B", // Lime
    "#512DA8", // Deep Purple
    "#E64A19", // Deep Orange
    "#0288D1", // Light Blue
    "#689F38", // Light Green
  ];

  PdfGanttChart({
    this.eventList,
    required this.calendarEntry,
    this.fromDate,
    this.toDate,
    this.calendarMode,
  }) : super() {
    viewRange = calculateNumberOfMonthsBetween(fromDate!, toDate!);
    if (calendarMode == "monthly") {
      viewRangeToFitScreen = 30;
    } else if (calendarMode == "daily") {
      viewRangeToFitScreen = 24; // 24 hours
    } else {
      viewRangeToFitScreen = 12;
    }
  }

  // Get consistent color for a calendar based on its ID
  PdfColor getCalendarColor(String calendarId) {
    final hash = calendarId.hashCode.abs();
    final colorHex = calendarColorHexes[hash % calendarColorHexes.length];
    return PdfColor.fromHex(colorHex);
  }

  int calculateNumberOfMonthsBetween(DateTime from, DateTime to) {
    if (calendarMode == "monthly") {
      return (to.day - from.day) + 1;
    } else if (calendarMode == "daily") {
      return 24; // 24 hours in a day
    } else {
      return to.month - from.month + 12 * (to.year - from.year) + 1;
    }
  }

  double calculateDistanceToLeftBorder(DateTime projectStartedAt) {
    if (calendarMode == "daily") {
      // For daily mode, calculate based on hours
      DateTime localStart = projectStartedAt.toLocal();
      double startHour = localStart.hour + (localStart.minute / 60.0);
      return startHour;
    }

    if (projectStartedAt.compareTo(fromDate!) <= 0) {
      return 0;
    } else {
      return (calculateNumberOfMonthsBetween(fromDate!, projectStartedAt) - 1)
          .toDouble();
    }
  }

  double calculateRemainingWidth(
      DateTime projectStartedAt, DateTime projectEndedAt) {
    if (calendarMode == "daily") {
      // For daily mode, calculate based on hours
      DateTime localStart = projectStartedAt.toLocal();
      DateTime localEnd = projectEndedAt.toLocal();

      double startHour = localStart.hour + (localStart.minute / 60.0);
      double endHour = localEnd.hour + (localEnd.minute / 60.0);

      // Calculate duration in hours
      double duration = endHour - startHour;

      // Handle events that span past midnight
      if (duration < 0) {
        duration += 24;
      }

      return duration;
    }

    int projectLength =
        calculateNumberOfMonthsBetween(projectStartedAt, projectEndedAt);
    if (projectStartedAt.compareTo(fromDate!) >= 0 &&
        projectStartedAt.compareTo(toDate!) <= 0) {
      if (projectLength <= viewRange) {
        return projectLength.toDouble();
      } else {
        return (viewRange -
                calculateNumberOfMonthsBetween(fromDate!, projectStartedAt))
            .toDouble();
      }
    } else if (projectStartedAt.isBefore(fromDate!) &&
        projectEndedAt.isBefore(fromDate!)) {
      return 0;
    } else if (projectStartedAt.isBefore(fromDate!) &&
        projectEndedAt.isBefore(toDate!)) {
      return (projectLength -
              calculateNumberOfMonthsBetween(projectStartedAt, fromDate!))
          .toDouble();
    } else if (projectStartedAt.isBefore(fromDate!) &&
        projectEndedAt.isAfter(toDate!)) {
      return viewRange.toDouble();
    }
    return 0;
  }

  List<pw.Widget> buildChartBars(List<google_api.Event> eventList,
      double chartViewWidth, google_api.CalendarListEntry calendarEntry) {
    final List<pw.Widget> chartBars = [];
    final calendarColor = getCalendarColor(calendarEntry.id!);

    for (int i = 0; i < eventList.length; i++) {
      DateTime startTime =
          eventList[i].start!.dateTime ?? eventList[i].start!.date!;
      DateTime endTime = eventList[i].end?.dateTime ?? eventList[i].end!.date!;

      // For all-day events in non-daily mode, subtract a day from end
      if (calendarMode != "daily" && eventList[i].start!.date != null) {
        endTime = endTime.subtract(const Duration(days: 1));
      }

      var remainingWidth = calculateRemainingWidth(startTime, endTime);
      if (remainingWidth > 0) {
        chartBars.add(
          pw.Container(
            height: 20.0,
            width: remainingWidth * chartViewWidth / viewRangeToFitScreen,
            margin: pw.EdgeInsets.only(
                left: calculateDistanceToLeftBorder(startTime) *
                    chartViewWidth /
                    viewRangeToFitScreen),
            alignment: pw.Alignment.center,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: calendarColor,
                borderRadius: pw.BorderRadius.circular(2.0),
              ),
              child: pw.SizedBox(
                width: remainingWidth * chartViewWidth / viewRangeToFitScreen,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    "${eventList[i].summary}",
                    maxLines: 1,
                    textAlign: pw.TextAlign.left,
                    style: const pw.TextStyle(
                      fontSize: 4,
                      color: PdfColors.white,
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

  pw.Widget buildHeader(double chartViewWidth, PdfColor color) {
    List<pw.Widget> headerItems = [];
    DateTime tempDate = fromDate!;
    headerItems.add(
      pw.Container(
        width: (chartViewWidth / viewRangeToFitScreen) + 24,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: PdfColors.grey, width: 0.5),
            right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
            bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5),
          ),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(2, 8, 2, 8),
          child: pw.Text('CALENDAR',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  fontSize: 6,
                  color: PdfColor.fromHex("#2C363F"),
                  fontWeight: pw.FontWeight.bold)),
        ),
      ),
    );

    for (int i = 0; i < viewRange; i++) {
      headerItems.add(
        pw.Container(
          width: chartViewWidth / viewRangeToFitScreen,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5),
              right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
            ),
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(2, 8, 2, 8),
            child: pw.Text(
              calendarMode == "daily"
                  ? i.toString() // Just show hour number (0-23)
                  : calendarMode == "monthly"
                      ? DateFormat.d().format(tempDate)
                      : DateFormat.yM().format(tempDate),
              textAlign: pw.TextAlign.center,
              style:
                  pw.TextStyle(fontSize: 6, color: PdfColor.fromHex("#E75A7C")),
            ),
          ),
        ),
      );
      if (calendarMode == "monthly") {
        tempDate = tempDate.add(const Duration(days: 1));
      } else if (calendarMode == "yearly") {
        tempDate = utils.DateUtils.nextMonth(tempDate);
      }
      // For daily mode, we don't need to increment tempDate
    }

    return pw.Container(
      height: 20.0,
      color: color,
      child: pw.Row(children: headerItems),
    );
  }

  pw.Widget buildGrid(double chartViewWidth) {
    List<pw.Widget> gridColumns = [];

    for (int i = 0; i <= viewRange; i++) {
      gridColumns.add(
        pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(
                right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
          ),
          width: i == 0
              ? (chartViewWidth / viewRangeToFitScreen) + 24
              : chartViewWidth / viewRangeToFitScreen,
        ),
      );
    }

    return pw.Row(
      children: gridColumns,
    );
  }

  pw.Widget buildChartForEachUser(List<google_api.Event> eventList,
      double chartViewWidth, google_api.CalendarListEntry calendarEntry) {
    var chartBars = buildChartBars(eventList, chartViewWidth, calendarEntry);

    return pw.SizedBox(
      height: chartBars.length < 5
          ? 5 * 19.0 + 35.0 + 11.0
          : chartBars.length * 19.0 + 35.0 + 11.0,
      child: pw.Row(
        children: <pw.Widget>[
          pw.Stack(
            fit: pw.StackFit.loose,
            children: <pw.Widget>[
              buildGrid(chartViewWidth),
              buildHeader(chartViewWidth, PdfColor.fromHex("#D6DBD2")),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20.0),
                child: pw.Column(
                  children: <pw.Widget>[
                    pw.Expanded(
                      child: pw.Row(
                        children: <pw.Widget>[
                          pw.Container(
                            width: chartViewWidth / viewRangeToFitScreen + 24,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex("#F2F5EA"),
                              border: const pw.Border(
                                bottom: pw.BorderSide(
                                    color: PdfColors.grey, width: 0.5),
                                left: pw.BorderSide(
                                    color: PdfColors.grey, width: 0.5),
                                right: pw.BorderSide(
                                    color: PdfColors.grey, width: 0.5),
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(4.0),
                                child: pw.Text(
                                  calendarEntry.summary!,
                                  style: pw.TextStyle(
                                      fontSize: 6,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black),
                                  textAlign: pw.TextAlign.center,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: chartBars,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<pw.Widget> buildChartContent(double chartViewWidth) {
    List<pw.Widget> chartContent = [];

    for (var calEntry in calendarEntry) {
      List<google_api.Event> ganttEvents = [];
      ganttEvents = eventList!
          .where((project) => project.organizer?.email == calEntry.id)
          .toList();

      // Filter events for daily mode to only show events on the selected day
      if (calendarMode == "daily" && fromDate != null) {
        ganttEvents = ganttEvents.where((event) {
          DateTime? eventStart =
              event.start?.dateTime?.toLocal() ?? event.start?.date?.toLocal();
          DateTime? eventEnd =
              event.end?.dateTime?.toLocal() ?? event.end?.date?.toLocal();

          if (eventStart == null || eventEnd == null) return false;

          // Check if event occurs on the selected day
          DateTime selectedDay =
              DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
          DateTime nextDay = selectedDay.add(const Duration(days: 1));

          // Event should start before the next day and end after the selected day starts
          return eventStart.isBefore(nextDay) && eventEnd.isAfter(selectedDay);
        }).toList();
      }

      chartContent
          .add(buildChartForEachUser(ganttEvents, chartViewWidth, calEntry));
    }

    return chartContent;
  }

  @override
  pw.Widget build(pw.Context context) {
    var chartViewWidth = calendarMode == "daily"
        ? 500.0 // Wider for 24 hour columns
        : calendarMode == "monthly"
            ? 190.0
            : 480.0;

    return pw.Wrap(
      direction: pw.Axis.vertical,
      children: buildChartContent(chartViewWidth),
    );
  }
}

Future<Uint8List> generateCalendar(
  PdfPageFormat pageFormat, {
  required List<google_api.CalendarListEntry> calendarEntry,
  List<google_api.Event>? eventList,
  final DateTime? fromDate,
  final DateTime? toDate,
  final String? calendarMode,
}) async {
  //Create a PDF document.
  final document = pw.Document();

  PdfGanttChart ganttChart = PdfGanttChart(
    calendarMode: calendarMode,
    fromDate: fromDate,
    toDate: toDate,
    calendarEntry: calendarEntry,
    eventList: eventList,
  );

  var chartViewWidth = calendarMode == "daily"
      ? 500.0 // Wider for 24 hour columns
      : calendarMode == "monthly"
          ? 195.0
          : 480.0;

  // Add a multipage PDF if the charts doesnot fit in a page
  document.addPage(
    pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
              base: await PdfGoogleFonts.openSansRegular(),
              bold: await PdfGoogleFonts.openSansBold()),
        ),
        build: (context) => ganttChart.buildChartContent(chartViewWidth)),
  );

  return document.save();
}
