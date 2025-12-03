import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';

class SimpleCircularLoader extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  final EdgeInsetsGeometry? padding;

  const SimpleCircularLoader({Key? key, this.color, this.strokeWidth = 8.0, this.padding}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(36.0),
      child: CircularProgressIndicator(color: color ?? AppColor.secondary, strokeWidth: strokeWidth!),
    );
  }
}
