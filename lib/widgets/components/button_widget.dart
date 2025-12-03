import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final Color buttonColor;
  final TextStyle textStyle;
  final double? buttonHeight;
  final void Function()? onTap;
  final BorderRadiusGeometry? borderRadius;
  final BorderRadius? splashBorderRadius;
  final Widget? prefixIcon;
  final double? buttonWidth;
  final bool? loader;
  const ButtonWidget({
    Key? key,
    required this.title,
    this.buttonColor = AppColor.secondary,
    this.onTap,
    this.textStyle = CustomTextStyle.bodyTextBold,
    this.buttonHeight = 48.0,
    this.borderRadius,
    this.prefixIcon,
    this.splashBorderRadius,
    this.buttonWidth,
    this.loader = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: buttonColor,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        borderRadius: splashBorderRadius ?? BorderRadius.circular(8),
        onTap: loader! ? () {} : onTap,
        child: SizedBox(
          width: buttonWidth ?? Utilities.screenWidth(context),
          height: buttonHeight,
          child: loader!
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColor.primaryLight, strokeWidth: 5),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    prefixIcon == null
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(right: 12, left: 12),
                            child: prefixIcon,
                          ),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: textStyle,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
