import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/info_field_widget.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      safeArea: false,
      backgroundColor: AppColor.primaryLight,
      appBar: AppBar(
        title: const AppBarTitle(title: "Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Material(
                elevation: 2,
                color: AppColor.white,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                        child: Center(
                          child: Material(
                            elevation: 4,
                            borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.primary, width: 5),
                                  shape: BoxShape.circle,
                                  color: AppColor.secondary),
                              child: user.photoURL == null
                                  ? Center(
                                      child:
                                          Text(getInitials(user.displayName ?? ""), style: CustomTextStyle.titleLight))
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(user.photoURL!),
                                      backgroundColor: AppColor.secondary,
                                      maxRadius: 100,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                        child: Center(
                          child: Text(
                            user.displayName ?? "",
                            style: CustomTextStyle.headerText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InfoFieldWidget(fieldInfo: user.email ?? " ---- ", fieldName: "EMAIL"),
                      const SizedBox(height: 12),
                      InfoFieldWidget(fieldInfo: user.phoneNumber ?? " ---- ", fieldName: "PHONE"),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
