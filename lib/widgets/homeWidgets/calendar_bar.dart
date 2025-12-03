import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class CalendarBar extends StatefulWidget {
  final Function() onAddCalendar;
  final Function() onAddEvent;
  final Function() onDownloadAsPDF;
  final Function onChangeLayout;
  final String? dropdownValue;

  const CalendarBar({
    super.key,
    required this.onAddCalendar,
    required this.onAddEvent,
    required this.onDownloadAsPDF,
    required this.onChangeLayout,
    this.dropdownValue,
  });

  @override
  _CalendarBarState createState() => _CalendarBarState();
}

class _CalendarBarState extends State<CalendarBar> {
  String? dropdownValue = 'MONTH';
  List<String> optionValue = ['MONTH', 'YEAR'];
  @override
  void initState() {
    super.initState();
    dropdownValue = widget.dropdownValue;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primaryLight,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: IconButton(
                tooltip: "Add Calendar",
                icon: const Icon(Icons.add_circle_outline, size: 32),
                onPressed: widget.onAddCalendar,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: IconButton(
                tooltip: "Add Event",
                icon: const Icon(Icons.event, size: 32),
                onPressed: widget.onAddEvent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: IconButton(
                tooltip: "Download PDF",
                icon: const Icon(Icons.picture_as_pdf, size: 32),
                onPressed: widget.onDownloadAsPDF,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButton(
                value: dropdownValue,
                dropdownColor: AppColor.primary,
                icon: const Icon(Icons.arrow_drop_down_outlined, size: 32, color: AppColor.primary),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                  widget.onChangeLayout(newValue);
                },
                style: CustomTextStyle.bodyTextLightBold.copyWith(fontFamily: "nunitoSans"),
                selectedItemBuilder: (BuildContext context) {
                  return optionValue.map((String value) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(value, style: CustomTextStyle.bodyTextBoldSecondary.copyWith(fontFamily: "nunitoSans")),
                      ],
                    );
                  }).toList();
                },
                elevation: 4,
                underline: const SizedBox(),
                items: optionValue
                    .map<DropdownMenuItem<String>>(
                      (item) => DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
