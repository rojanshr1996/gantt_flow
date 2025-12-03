import 'package:flutter/material.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/ganttLogoTrans.png',
                  height: 150,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Update Available',
                style: CustomTextStyle.headerTextAccent.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'A new version of Gantt Flow is available. Update now to enhance your app experience. Thank you!',
                style: CustomTextStyle.bodyTextAccent,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ButtonWidget(
                buttonWidth: MediaQuery.of(context).size.width,
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.thoughtsphere.gantt_flow',
                  );
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  } catch (e) {
                    debugPrint('Error launching store: $e');
                  }
                },
                title: "UPDATE",
                textStyle: CustomTextStyle.bodyTextLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
