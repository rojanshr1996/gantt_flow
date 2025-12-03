import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class NoDataWidget extends StatelessWidget {
  final String title;
  final TextStyle? textStyle;

  const NoDataWidget({
    Key? key,
    required this.title,
    this.textStyle,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          decoration: BoxDecoration(color: AppColor.pale.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: textStyle ?? CustomTextStyle.bodyTextBold),
          )),
    );
  }
}

class RefreshNoData extends StatelessWidget {
  final String title;
  final TextStyle? textStyle;

  const RefreshNoData({
    Key? key,
    required this.title,
    this.textStyle,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(),
        NoDataWidget(title: title, textStyle: textStyle),
      ],
    );
  }
}
