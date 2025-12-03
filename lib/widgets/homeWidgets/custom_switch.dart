import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class CustomSwitch extends StatelessWidget {
  final String title;
  final bool switchValue;
  final Function(bool)? onChanged;
  final double fontSize;
  final TextStyle? textStyle;
  final Color? trackColor;
  final Color? thumbColor;

  const CustomSwitch(
      {Key? key,
      required this.title,
      required this.switchValue,
      this.onChanged,
      this.fontSize = 18.0,
      this.textStyle = CustomTextStyle.largeTextBold,
      this.trackColor,
      this.thumbColor})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: textStyle,
            ),
          ),
          Platform.isIOS
              ? CupertinoSwitch(
                  trackColor: switchValue ? AppColor.primaryLight : trackColor ?? AppColor.primaryDark,
                  thumbColor: switchValue ? AppColor.light : thumbColor ?? AppColor.pale,
                  value: switchValue,
                  onChanged: onChanged,
                  activeColor: AppColor.secondary,
                )
              : Switch(
                  activeTrackColor: AppColor.secondary,
                  activeColor: AppColor.light,
                  inactiveThumbColor: AppColor.primary,
                  inactiveTrackColor: AppColor.pale,
                  value: switchValue,
                  onChanged: onChanged,
                ),
        ],
      ),
    );
  }
}
