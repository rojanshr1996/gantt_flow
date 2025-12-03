import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gantt_mobile/styles/app_color.dart';

class SafeHeader extends StatelessWidget {
  final Widget child;
  final Color? color;
  final bool? top;
  final bool? bottom;
  final bool? left;
  final bool? right;

  const SafeHeader({Key? key, required this.child, this.color, this.top, this.bottom, this.left, this.right})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? AppColor.primary,
      child: SafeArea(
        top: top ?? true,
        right: right ?? true,
        left: left ?? true,
        bottom: bottom ?? false,
        child: child,
      ),
    );
  }
}
