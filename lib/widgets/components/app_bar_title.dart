import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class AppBarTitle extends StatelessWidget {
  final String? title;
  final TextStyle? textStyle;
  const AppBarTitle({Key? key, this.title, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title ?? "",
        style: textStyle ?? CustomTextStyle.largeTextLightBold);
  }
}
