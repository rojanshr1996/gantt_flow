import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class InfoFieldWidget extends StatelessWidget {
  final String fieldName;
  final String fieldInfo;

  final TextStyle? fieldNameStyle;
  final TextStyle? fieldInfoStyle;

  const InfoFieldWidget({
    Key? key,
    required this.fieldName,
    required this.fieldInfo,
    this.fieldNameStyle,
    this.fieldInfoStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldName, style: fieldNameStyle ?? CustomTextStyle.hintSmallText),
        const SizedBox(height: 2),
        Container(
          width: Utilities.screenWidth(context),
          decoration: BoxDecoration(color: AppColor.light, borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(16),
          child: Text(
            fieldInfo,
            style: fieldInfoStyle ?? CustomTextStyle.bodyTextBold,
          ),
        ),
      ],
    );
  }
}
