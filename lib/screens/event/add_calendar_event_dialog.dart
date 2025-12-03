import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/no_data_widget.dart';
import 'package:gantt_mobile/widgets/components/simple_circular_loader.dart';
import 'package:gantt_mobile/widgets/homeWidgets/calendar_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart';

class AddCalendarEventDialog extends StatefulWidget {
  const AddCalendarEventDialog({Key? key}) : super(key: key);

  @override
  _AddCalendarEventDialogState createState() => _AddCalendarEventDialogState();
}

class _AddCalendarEventDialogState extends State<AddCalendarEventDialog> {
  List<String> encodedCalendarList = [];
  List<CalendarListEntry> calendarList = [];
  bool isLoading = false;

  @override
  void initState() {
    isLoading = true;
    super.initState();
    getCalendarFromPref();
  }

  getCalendarFromPref() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    encodedCalendarList =
        _sharedPreferences.getStringList("calendarList") ?? [];

    if (encodedCalendarList.isNotEmpty) {
      for (String value in encodedCalendarList) {
        CalendarListEntry item = CalendarListEntry.fromJson(json.decode(value));
        if (calendarList.every((data) => data.id != item.id)) {
          calendarList
              .add(item); //Add calendar to the list to show in the chart
        }
      }
    }
    isLoading = false;
    setState(() {});
    debugPrint("ENCODED CALENDARS: ${calendarList.length}");
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsetsGeometry contentPadding =
        EdgeInsets.fromLTRB(12, 24, 12, 0);

    return Dialog(
      backgroundColor: AppColor.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: contentPadding,
            child: Text(
              'Select calendar for the event',
              style: CustomTextStyle.bodyTextBold,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: calendarList.isEmpty
                    ? Utilities.screenHeight(context) * 0.2
                    : Utilities.screenHeight(context) * 0.6),
            child: isLoading
                ? const SimpleCircularLoader()
                : Padding(
                    padding: contentPadding,
                    child: calendarList.isEmpty
                        ? const NoDataWidget(title: "No data")
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: calendarList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: CalendarListItem(
                                  name: calendarList[index].summary!,
                                  onTap: () {
                                    Utilities.returnDataCloseActivity(
                                        context, calendarList[index]);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () => Utilities.closeActivity(context),
              child: const Text('CANCEL',
                  style: CustomTextStyle.bodyTextSecondary),
            ),
          )
        ],
      ),
    );
  }
}
