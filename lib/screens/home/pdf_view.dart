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

  PdfGanttChart({
    this.eventList,
    required this.calendarEntry,
    this.fromDate,
    this.toDate,
    this.calendarMode,
  }) : super() {
    viewRange = calculateNumberOfMonthsBetween(fromDate!, toDate!);
    if (calendarMode == "monthyl") {
      viewRangeToFitScreen = 30;
    } else {
      viewRangeToFitScreen = 12;
    }
  }

  int calculateNumberOfMonthsBetween(DateTime from, DateTime to) {
    if (calendarMode == "monthly") {
      return (to.day - from.day) + 1;
    } else {
      return to.month - from.month + 12 * (to.year - from.year) + 1;
    }
  }

  int calculateDistanceToLeftBorder(DateTime projectStartedAt) {
    if (projectStartedAt.compareTo(fromDate!) <= 0) {
      return 0;
    } else {
      return calculateNumberOfMonthsBetween(fromDate!, projectStartedAt) - 1;
    }
  }

  int calculateRemainingWidth(DateTime projectStartedAt, DateTime projectEndedAt) {
    int projectLength = calculateNumberOfMonthsBetween(projectStartedAt, projectEndedAt);
    if (projectStartedAt.compareTo(fromDate!) >= 0 && projectStartedAt.compareTo(toDate!) <= 0) {
      if (projectLength <= viewRange) {
        return projectLength;
      } else {
        return viewRange - calculateNumberOfMonthsBetween(fromDate!, projectStartedAt);
      }
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isBefore(fromDate!)) {
      return 0;
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isBefore(toDate!)) {
      return projectLength - calculateNumberOfMonthsBetween(projectStartedAt, fromDate!);
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isAfter(toDate!)) {
      return viewRange;
    }
    return 0;
  }

  List<pw.Widget> buildChartBars(
      List<google_api.Event> eventList, double chartViewWidth, google_api.CalendarListEntry calendarEntry) {
    final List<pw.Widget> chartBars = [];

    for (int i = 0; i < eventList.length; i++) {
      var remainingWidth = calculateRemainingWidth(eventList[i].start!.dateTime ?? eventList[i].start!.date!,
          eventList[i].end?.dateTime ?? eventList[i].end!.date!.subtract(const Duration(days: 1)));
      if (remainingWidth > 0) {
        chartBars.add(
          pw.Container(
            height: 20.0,
            width: remainingWidth * chartViewWidth / viewRangeToFitScreen,
            margin: pw.EdgeInsets.only(
                left: calculateDistanceToLeftBorder(eventList[i].start?.dateTime ?? eventList[i].start!.date!) *
                    chartViewWidth /
                    viewRangeToFitScreen),
            alignment: pw.Alignment.center,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#2C363F"),
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
              style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex("#2C363F"), fontWeight: pw.FontWeight.bold)),
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
              calendarMode == "monthly" ? DateFormat.d().format(tempDate) : DateFormat.yM().format(tempDate),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 6, color: PdfColor.fromHex("#E75A7C")),
            ),
          ),
        ),
      );
      calendarMode == "monthly"
          ? tempDate = tempDate.add(const Duration(days: 1))
          : tempDate = utils.DateUtils.nextMonth(tempDate);
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
          width: i == 0 ? (chartViewWidth / viewRangeToFitScreen) + 24 : chartViewWidth / viewRangeToFitScreen,
        ),
      );
    }

    return pw.Row(
      children: gridColumns,
    );
  }

  pw.Widget buildChartForEachUser(
      List<google_api.Event> eventList, double chartViewWidth, google_api.CalendarListEntry calendarEntry) {
    var chartBars = buildChartBars(eventList, chartViewWidth, calendarEntry);

    return pw.SizedBox(
      height: chartBars.length < 5 ? 5 * 19.0 + 35.0 + 11.0 : chartBars.length * 19.0 + 35.0 + 11.0,
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
                                bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                                left: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                                right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                              ),
                            ),
                            child: pw.Center(
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(4.0),
                                child: pw.Text(
                                  calendarEntry.summary!,
                                  style:
                                      pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
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
      ganttEvents = eventList!.where((project) => project.organizer?.email == calEntry.id).toList();
      chartContent.add(buildChartForEachUser(ganttEvents, chartViewWidth, calEntry));
    }

    return chartContent;
  }

  @override
  pw.Widget build(pw.Context context) {
    var chartViewWidth = calendarMode == "monthly" ? 190.0 : 480.0;

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

  var chartViewWidth = calendarMode == "monthly" ? 195.0 : 480.0;

  // Add a multipage PDF if the charts doesnot fit in a page
  document.addPage(
    pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
              base: await PdfGoogleFonts.openSansRegular(), bold: await PdfGoogleFonts.openSansBold()),
        ),
        build: (context) => ganttChart.buildChartContent(chartViewWidth)),
  );

  return document.save();
}
