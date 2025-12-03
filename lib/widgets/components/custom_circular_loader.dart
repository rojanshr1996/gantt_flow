import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/styles/app_color.dart';

class CustomCircularLoader extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  final EdgeInsetsGeometry? padding;
  const CustomCircularLoader({Key? key, this.color, this.strokeWidth = 8.0, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primaryDark.withOpacity(0.2),
      height: Utilities.screenHeight(context),
      width: Utilities.screenWidth(context),
      child: Center(
        child: Material(
          borderRadius: BorderRadius.circular(50),
          elevation: 3,
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(color: AppColor.primary, shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: color ?? AppColor.secondary, strokeWidth: strokeWidth!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
