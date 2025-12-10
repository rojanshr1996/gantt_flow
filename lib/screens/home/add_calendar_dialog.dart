import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/home/calendar_service_provider.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/no_data_widget.dart';
import 'package:gantt_mobile/widgets/components/simple_circular_loader.dart';
import 'package:gantt_mobile/widgets/homeWidgets/calendar_list_item.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCalendarDialog extends StatefulWidget {
  final bool fromEvent;
  const AddCalendarDialog({super.key, this.fromEvent = false});

  @override
  _AddCalendarDialogState createState() => _AddCalendarDialogState();
}

class _AddCalendarDialogState extends State<AddCalendarDialog> {
  List<CalendarListEntry> calendarList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUserData().then((data) {
      debugPrint(data.toString());
      getCalendar(context);
    });
  }

  Future<void> getCalendar(BuildContext context) async {
    final calProvider =
        Provider.of<CalendarServiceProvider>(context, listen: false);
    final authProvider =
        Provider.of<AuthServiceProvider>(context, listen: false);
    authProvider.refreshToken().then((data) async {
      if (data != "exception") {
        final result = await calProvider.getCalendarList(context);
        isLoading = false;
        setState(() {});
        if (result != null && result != "exception") {
          debugPrint("THIS IS CALENDAR LIST: $result");
          final List<CalendarListEntry> resultList =
              (result as List).cast<CalendarListEntry>();
          if (resultList.isNotEmpty) {
            calendarList = resultList;
          }
        }
      } else {
        tokenExpire(context);
      }
    });
  }

  Future getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.getString("authUser");
    sharedPreferences.getString("authUserHeader");

    debugPrint(sharedPreferences.getString("authUser"));
    if (sharedPreferences.getString("authUserHeader") != null) {
      return json.decode(sharedPreferences.getString("authUserHeader")!);
    }
    return;
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
              'Add Calendar to schedule',
              style: CustomTextStyle.bodyTextBold,
            ),
          ),
          Consumer<CalendarServiceProvider>(
            builder: (context, calProvider, _) {
              return ConstrainedBox(
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
              );
            },
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
