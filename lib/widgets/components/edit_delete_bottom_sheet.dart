import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';

class EditDeleteBottomSheet extends StatelessWidget {
  final Function()? editFunction;
  final Function() deleteFunction;

  const EditDeleteBottomSheet({Key? key, this.editFunction, required this.deleteFunction}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primary,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Container(
                height: 4,
                width: Utilities.screenWidth(context) * 0.1,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: AppColor.secondary),
              ),
            ),
            editFunction == null
                ? Container()
                : ListTile(
                    onTap: editFunction,
                    leading: const Icon(Icons.edit_outlined, color: AppColor.secondary),
                    title: const Text("EDIT", style: CustomTextStyle.bodyTextLightBold),
                  ),
            ListTile(
              onTap: deleteFunction,
              leading: const Icon(Icons.delete, color: AppColor.secondary),
              title: const Text("DELETE", style: CustomTextStyle.bodyTextLightBold),
            ),
            SizedBox(height: Utilities.screenHeight(context) * 0.02),
          ],
        ),
      ),
    );
  }
}
