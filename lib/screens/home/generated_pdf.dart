import 'package:flutter/material.dart';
import 'package:gantt_mobile/screens/home/pdf_view.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/remove_focus.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:googleapis/calendar/v3.dart' as google_api;

class GeneratedPdf extends StatefulWidget {
  final List<google_api.Event>? eventList;
  final List<google_api.CalendarListEntry> calendarEntry;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? calendarMode;
  final Function()? onEventTap;
  const GeneratedPdf({
    Key? key,
    this.eventList,
    required this.calendarEntry,
    this.fromDate,
    this.toDate,
    required this.calendarMode,
    this.onEventTap,
  }) : super(key: key);

  @override
  _GeneratedPdfState createState() => _GeneratedPdfState();
}

class _GeneratedPdfState extends State<GeneratedPdf> {
  bool isLoading = false;
  Event? eventDetail;
  bool loader = false;

  @override
  Widget build(BuildContext context) {
    return RemoveFocus(
      child: BackgroundScaffold(
          safeArea: false,
          backgroundColor: AppColor.primaryLight,
          appBar: AppBar(
            title: const AppBarTitle(title: "Gantt Chart"),
          ),
          body: PdfPreview(
            initialPageFormat: PdfPageFormat.a4,
            canDebug: false,
            dynamicLayout: false,
            allowPrinting: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            build: (format) => generateCalendar(format,
                calendarMode: widget.calendarMode,
                fromDate: widget.fromDate,
                toDate: widget.toDate,
                calendarEntry: widget.calendarEntry,
                eventList: widget.eventList),
          )),
    );
  }
}
