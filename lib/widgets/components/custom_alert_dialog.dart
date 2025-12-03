import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/widgets/components/two_button_widget.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final TextStyle? titleTextStyle;

  final Widget? body;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle? contentTextStyle;

  final String? leftButtonText;
  final Function()? leftButtonFunction;

  final String? rightButtonText;
  final Function()? rightButtonFunction;

  final EdgeInsetsGeometry actionsPadding;

  final bool scrollable;

  const CustomAlertDialog({
    Key? key,
    this.leftButtonText,
    this.rightButtonText,
    this.title,
    this.body,
    this.leftButtonFunction,
    this.rightButtonFunction,
    this.scrollable = false,
    this.contentPadding = const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
    this.titlePadding,
    this.titleTextStyle,
    this.contentTextStyle,
    this.actionsPadding = const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double paddingScaleFactor = _paddingScaleFactor(MediaQuery.of(context).textScaleFactor);
    final TextDirection textDirection = Directionality.of(context);
    Widget? titleWidget;
    Widget? contentWidget;

    if (title != null) {
      final EdgeInsets defaultTitlePadding = EdgeInsets.fromLTRB(18.0, 18.0, 18.0, body == null ? 8.0 : 0.0);
      final EdgeInsets effectiveTitlePadding = titlePadding?.resolve(textDirection) ?? defaultTitlePadding;
      titleWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveTitlePadding.left * paddingScaleFactor,
          right: effectiveTitlePadding.right * paddingScaleFactor,
          top: effectiveTitlePadding.top * paddingScaleFactor,
          bottom: effectiveTitlePadding.bottom,
        ),
        child: Semantics(
          child: title,
          namesRoute: true,
          container: true,
        ),
      );
    }

    if (body != null) {
      final EdgeInsets effectiveContentPadding = contentPadding.resolve(textDirection);
      contentWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveContentPadding.left * paddingScaleFactor,
          right: effectiveContentPadding.right * paddingScaleFactor,
          top: title == null ? effectiveContentPadding.top * paddingScaleFactor : effectiveContentPadding.top,
          bottom: effectiveContentPadding.bottom,
        ),
        child: body,
      );
    }

    List<Widget> columnChildren;
    if (scrollable) {
      columnChildren = <Widget>[
        if (body != null)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (title != null) titleWidget!,
                  if (body != null) contentWidget!,
                ],
              ),
            ),
          ),
        TwoButtonWidget(
          leftButtonFunction: leftButtonFunction,
          leftButtonText: leftButtonText,
          rightButtonText: rightButtonText,
          rightButtonFuntion: rightButtonFunction,
        ),
        const SizedBox(height: 4),
      ];
    } else {
      columnChildren = <Widget>[
        if (title != null) titleWidget!,
        if (body != null) Flexible(child: contentWidget!),
        Padding(
          padding: actionsPadding,
          child: TwoButtonWidget(
            leftButtonFunction: leftButtonFunction,
            leftButtonText: leftButtonText,
            rightButtonText: rightButtonText,
            rightButtonFuntion: rightButtonFunction,
          ),
        ),
        const SizedBox(height: 4),
      ];
    }

    Widget dialogChild = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      ),
    );

    return Dialog(
      backgroundColor: AppColor.primary,
      elevation: 3,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      clipBehavior: Clip.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: dialogChild,
    );
  }
}

double _paddingScaleFactor(double textScaleFactor) {
  final double clampedTextScaleFactor = textScaleFactor.clamp(1.0, 2.0).toDouble();
  // The final padding scale factor is clamped between 1/3 and 1. For example,
  // a non-scaled padding of 24 will produce a padding between 24 and 8.
  return lerpDouble(1.0, 1.0 / 3.0, clampedTextScaleFactor - 1.0)!;
}
