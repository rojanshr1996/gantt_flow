import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/providers/app_update_provider.dart';
import 'package:gantt_mobile/screens/app_update_screen.dart';
import 'package:gantt_mobile/screens/auth/index_screen.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  Future<Timer> startTime() async {
    var duration = const Duration(milliseconds: 2000);
    return Timer(duration, () {
      navigationPage();
    });
  }

  void navigationPage() async {
    final appUpdateProvider =
        Provider.of<AppUpdateProvider>(context, listen: false);
    await appUpdateProvider.checkForUpdate();

    if (appUpdateProvider.isUpdateRequired) {
      Utilities.fadeReplaceActivity(context, const AppUpdateScreen());
    } else {
      Utilities.fadeReplaceActivity(context, const IndexScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      safeArea: false,
      backgroundColor: Colors.white,
      body: Container(
        color: AppColor.white,
        height: MediaQuery.of(context).size.height,
        width: Utilities.screenWidth(context),
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(36.0),
                          child: Image.asset(
                            'assets/images/ganttLogoTrans.png',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
