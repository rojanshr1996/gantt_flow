import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class TwoButtonWidget extends StatelessWidget {
  final String? leftButtonText;
  final String? rightButtonText;
  final Function()? leftButtonFunction;
  final Function()? rightButtonFuntion;
  final bool transparentColor;
  final double buttonHeight;
  final Color? buttonColor;
  final TextStyle rightButtonTextStyle;
  final TextStyle leftButtonTextStyle;
  final bool switchButtonDecoration;

  const TwoButtonWidget({
    Key? key,
    this.leftButtonText,
    this.rightButtonText,
    this.leftButtonFunction,
    this.rightButtonFuntion,
    this.transparentColor = false,
    this.buttonHeight = 48.0,
    this.buttonColor,
    this.rightButtonTextStyle = CustomTextStyle.bodyTextLight,
    this.leftButtonTextStyle = CustomTextStyle.bodyTextLight,
    this.switchButtonDecoration = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        leftButtonText == null
            ? Container()
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Material(
                    color: switchButtonDecoration ? AppColor.transparent : buttonColor ?? AppColor.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: leftButtonFunction,
                      child: Container(
                        height: buttonHeight,
                        decoration: switchButtonDecoration
                            ? BoxDecoration(
                                border: Border.all(color: buttonColor ?? AppColor.secondary, width: 1.5),
                                borderRadius: const BorderRadius.all(Radius.circular(8)))
                            : const BoxDecoration(),
                        child: Center(
                            child: Text(
                          leftButtonText!.toUpperCase(),
                          style: switchButtonDecoration ? rightButtonTextStyle : leftButtonTextStyle,
                        )),
                      ),
                    ),
                  ),
                ),
              ),
        rightButtonText == null
            ? Container()
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Material(
                    color: switchButtonDecoration ? AppColor.secondary : AppColor.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: rightButtonFuntion,
                      child: Container(
                        decoration: switchButtonDecoration
                            ? const BoxDecoration()
                            : BoxDecoration(
                                border: Border.all(color: buttonColor ?? AppColor.secondary, width: 1),
                                borderRadius: const BorderRadius.all(Radius.circular(8))),
                        height: buttonHeight,
                        child: Center(
                            child: Text(
                          rightButtonText!,
                          style: switchButtonDecoration ? leftButtonTextStyle : rightButtonTextStyle,
                        )),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
