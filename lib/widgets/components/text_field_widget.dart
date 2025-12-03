import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String? hintText;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function(String)? onFormSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool headingField;
  final String? title;
  final int? maxLines;
  final Color? headerColor;
  final bool? enabled;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final int? maxLength;
  final bool? filled;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextCapitalization textCapitalization;

  const TextFieldWidget(
      {Key? key,
      this.textEditingController,
      this.hintText,
      this.textInputType,
      this.obscureText = false,
      this.validator,
      this.onChanged,
      this.suffixIcon,
      this.headingField = false,
      this.title,
      this.maxLines,
      this.headerColor,
      this.prefixIcon,
      this.enabled = true,
      this.autofocus = false,
      this.onTap,
      this.contentPadding,
      this.enabledBorder = const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.primary, width: 1)),
      this.disabledBorder = const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.muted, width: 1)),
      this.focusedBorder = const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.primaryDark, width: 1.5)),
      this.errorBorder = const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.danger, width: 1.5)),
      this.onFormSubmitted,
      this.textInputAction,
      this.maxLength,
      this.filled = false,
      this.fillColor,
      this.hintStyle = CustomTextStyle.hintText,
      this.style,
      this.textCapitalization = TextCapitalization.sentences})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: headingField ? 14 : 0),
        headingField
            ? Text(
                title ?? "",
                style: TextStyle(fontSize: 14, color: headerColor ?? AppColor.primary),
              )
            : Container(),
        TextFormField(
          enabled: enabled,
          maxLength: maxLength,
          onChanged: onChanged,
          obscureText: obscureText,
          controller: textEditingController,
          autofocus: autofocus,
          autocorrect: false,
          validator: validator,
          enableSuggestions: false,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          onTap: onTap,
          onFieldSubmitted: onFormSubmitted,
          textCapitalization: textCapitalization,
          style: style ?? CustomTextStyle.bodyText,
          decoration: InputDecoration(
            fillColor: fillColor,
            filled: filled,
            contentPadding: contentPadding,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            hintText: hintText,
            errorStyle: CustomTextStyle.bodyTextDanger,
            focusedBorder: focusedBorder,
            enabledBorder: enabledBorder,
            disabledBorder: disabledBorder,
            errorBorder: errorBorder,
            errorMaxLines: 2,
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.danger, width: 1.5),
            ),
            hintStyle: hintStyle,
          ),
        ),
      ],
    );
  }
}
