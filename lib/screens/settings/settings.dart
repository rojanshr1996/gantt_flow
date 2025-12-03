import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/auth/index_screen.dart';
import 'package:gantt_mobile/screens/profile/profile.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/app_bar_title.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/custom_circular_loader.dart';
import 'package:gantt_mobile/widgets/homeWidgets/calendar_list_item.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool showNotification = true;
  bool loader = false;

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      safeArea: false,
      backgroundColor: AppColor.primaryLight,
      appBar: AppBar(
        title: const AppBarTitle(title: "Settings"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListView(
                              children: [
                                // CalendarListItem(
                                //   name: "Notification",
                                //   leadingIcon: Icons.notifications,
                                //   trailing: Platform.isIOS
                                //       ? CupertinoSwitch(
                                //           trackColor: showNotification ? AppColor.primaryLight : AppColor.primaryDark,
                                //           thumbColor: showNotification ? AppColor.light : AppColor.pale,
                                //           value: showNotification,
                                //           onChanged: (value) {
                                //             setState(() {
                                //               showNotification = value;
                                //             });
                                //           },
                                //           activeColor: AppColor.secondary,
                                //         )
                                //       : Switch(
                                //           activeTrackColor: AppColor.secondary,
                                //           activeColor: AppColor.light,
                                //           inactiveThumbColor: AppColor.pale,
                                //           value: showNotification,
                                //           onChanged: (bool value) {
                                //             setState(() {
                                //               showNotification = value;
                                //             });
                                //           },
                                //         ),
                                // ),
                                // const SizedBox(height: 8),
                                CalendarListItem(
                                  name: "Profile",
                                  leadingIcon: Icons.account_circle,
                                  onTap: () => Utilities.openActivity(context, const Profile()),
                                ),
                                const SizedBox(height: 8),
                                CalendarListItem(
                                  name: "Sign out",
                                  leadingIcon: Icons.logout,
                                  onTap: () => logout(
                                      context: context,
                                      leftButtonFunction: () {
                                        Utilities.closeActivity(context);
                                        setState(() {
                                          loader = true;
                                        });
                                        final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);
                                        authProvider.logout().then((value) {
                                          debugPrint("$value");
                                          if (value != "exception") {
                                            clearUser();
                                            clearCalendarEvent();
                                            setState(() {
                                              loader = false;
                                            });
                                            showToast(message: "Sign-out successful");
                                            Utilities.removeStackActivity(context, const IndexScreen());
                                          }
                                        });
                                      },
                                      rightButtonFunction: () {
                                        Utilities.closeActivity(context);
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          borderRadius:
                              const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                          elevation: 2,
                          color: AppColor.primaryLight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Gantt Flow V0.0.1",
                                    style: CustomTextStyle.bodyTextAccent
                                        .copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.normal),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          loader ? const CustomCircularLoader() : Container()
        ],
      ),
    );
  }
}
