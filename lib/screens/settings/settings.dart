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
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ValueNotifier<bool> _loader = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

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
                              physics: const ClampingScrollPhysics(),
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
                                  onTap: () => Utilities.openActivity(
                                      context, const Profile()),
                                ),
                                const SizedBox(height: 8),
                                CalendarListItem(
                                  name: "About",
                                  leadingIcon: Icons.info_outline,
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext ctx) => AlertDialog(
                                      title: const Text("About Gantt Flow",
                                          style:
                                              CustomTextStyle.headerTextAccent),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Visualize Time, Organize Life",
                                              style: CustomTextStyle
                                                  .bodyTextAccentBold
                                                  .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Gantt Flow transforms your Google Calendar into a powerful visual timeline. "
                                              "View your events as an intuitive Gantt chart, making it easy to see how your time flows across days, weeks, and months. "
                                              "Seamlessly manage multiple calendars, create events, and get a bird's-eye view of your schedule. "
                                              "Perfect for professionals, students, and anyone who wants to master their time management.",
                                              style: CustomTextStyle
                                                  .bodyTextAccent,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text("CLOSE",
                                              style: CustomTextStyle
                                                  .bodyTextAccentBold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CalendarListItem(
                                  name: "Privacy Policy",
                                  leadingIcon: Icons.privacy_tip_outlined,
                                  onTap: () async {
                                    final Uri url = Uri.parse(
                                        'https://www.freeprivacypolicy.com/live/b2a1fdd5-bca9-42c1-9d38-9d348568229f');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      showToast(
                                          message:
                                              "Could not open privacy policy");
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                CalendarListItem(
                                  name: "Terms & Conditions",
                                  leadingIcon: Icons.description_outlined,
                                  onTap: () async {
                                    final Uri url = Uri.parse(
                                        'https://www.freeprivacypolicy.com/live/6cdec090-e11e-4483-b45f-705733872437');
                                    try {
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        showToast(
                                            message:
                                                "Could not open terms & conditions");
                                      }
                                    } catch (e) {
                                      debugPrint("Error launching URL: $e");
                                      showToast(
                                          message:
                                              "Could not open terms & conditions");
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                CalendarListItem(
                                  name: "Sign out",
                                  leadingIcon: Icons.logout,
                                  onTap: () => logout(
                                      context: context,
                                      leftButtonFunction: () {
                                        Utilities.closeActivity(context);
                                        _loader.value = true;
                                        final authProvider =
                                            Provider.of<AuthServiceProvider>(
                                                context,
                                                listen: false);
                                        authProvider.logout().then((value) {
                                          debugPrint("$value");
                                          if (value != "exception") {
                                            clearUser();
                                            // Don't clear calendar data - let it persist for next login
                                            // clearCalendarEvent();
                                            _loader.value = false;
                                            showToast(
                                                message: "Sign-out successful");
                                            Utilities.removeStackActivity(
                                                context, const IndexScreen());
                                          } else {
                                            _loader.value = false;
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
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                          elevation: 2,
                          color: AppColor.primaryLight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Gantt Flow V1.0.0",
                                    style: CustomTextStyle.bodyTextAccent
                                        .copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.normal),
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
          ValueListenableBuilder<bool>(
            valueListenable: _loader,
            builder: (context, isLoading, child) {
              return isLoading
                  ? const CustomCircularLoader()
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}
