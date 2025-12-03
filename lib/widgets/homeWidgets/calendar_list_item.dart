import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class CalendarListItem extends StatelessWidget {
  final String name;
  final Function()? onTap;
  final Function()? onTrailingTap;
  final Widget? trailing;
  final Color? itemColor;
  final IconData? leadingIcon;

  const CalendarListItem(
      {Key? key, this.name = "", this.onTap, this.onTrailingTap, this.trailing, this.itemColor, this.leadingIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      color: itemColor ?? AppColor.primary,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  leadingIcon ?? Icons.event,
                  color: AppColor.light,
                ),
              ),
              Expanded(
                child: Text(
                  name,
                  style: CustomTextStyle.subtitleTextLight,
                  softWrap: true,
                ),
              ),
              trailing == null
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: trailing,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
