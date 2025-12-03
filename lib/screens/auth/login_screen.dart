import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gantt_mobile/base/extra_functions.dart';
import 'package:gantt_mobile/base/utilities.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:gantt_mobile/styles/custom_text_style.dart';
import 'package:gantt_mobile/widgets/components/background_scaffold.dart';
import 'package:gantt_mobile/widgets/components/button_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundColor: AppColor.primary,
      body: SizedBox(
        height: Utilities.screenHeight(context),
        width: Utilities.screenWidth(context),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 36, 12, 36),
                    child: SizedBox(
                      height: Utilities.screenHeight(context) * 0.3,
                      child: Image.asset("assets/images/mailBulk.png"),
                    ),
                  ),
                  const Text("GANTT LOGIN", style: CustomTextStyle.titleLight),
                ],
              ),
            ),
            Consumer<AuthServiceProvider>(
              builder: (context, authProvider, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: ButtonWidget(
                    title: authProvider.authWaiting ? "" : "SIGN IN WITH GOOGLE",
                    borderRadius: BorderRadius.circular(8),
                    buttonColor: AppColor.danger,
                    onTap: () async {
                      debugPrint("Open google sign in");
                      authProvider.authWaiting = true;
                      try {
                        // Calls the google login function
                        final result = await authProvider.googleLogIn();
                        authProvider.authWaiting = false;
                        debugPrint("This is the result: $result");

                        // Only navigate if sign-in was successful
                        if (result != null && result != "exception" && result != "cancelled") {
                          showToast(message: "Sign-in successful");
                          // Navigation is handled by IndexScreen's StreamBuilder
                          // which listens to Firebase auth state changes
                        } else if (result == "cancelled") {
                          debugPrint("User cancelled sign-in");
                          // Don't show error toast for user cancellation
                        } else {
                          debugPrint("Sign-in failed");
                          // Error toast is already shown in googleLogIn method
                        }
                      } catch (error) {
                        authProvider.authWaiting = false;
                        debugPrint("Sign-in exception: $error");
                        showToast(message: "An unexpected error occurred. Please try again.");
                      }
                    },
                    textStyle: CustomTextStyle.bodyTextLight,
                    prefixIcon: const FaIcon(FontAwesomeIcons.google, color: AppColor.primaryLight),
                    loader: authProvider.authWaiting ? true : false,
                  ),
                );
              },
            ),
            SizedBox(height: Utilities.screenHeight(context) * 0.12)
          ],
        ),
      ),
    );
  }
}
