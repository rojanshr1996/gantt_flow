import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gantt_mobile/screens/auth/auth_service_provider.dart';
import 'package:gantt_mobile/screens/event/event_service_provider.dart';
import 'package:gantt_mobile/screens/home/calendar_service_provider.dart';
import 'package:gantt_mobile/screens/splash_screen.dart';
import 'package:gantt_mobile/styles/app_color.dart';
import 'package:provider/provider.dart';

// global RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthServiceProvider()),
        ChangeNotifierProvider(create: (context) => CalendarServiceProvider()),
        ChangeNotifierProvider(create: (context) => EventServiceProvider()),
      ],
      child: MaterialApp(
        title: 'Gantt Flow',
        navigatorObservers: <NavigatorObserver>[routeObserver],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: primarySwatch,
            primaryColor: AppColor.primary,
            highlightColor: AppColor.transparent,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'nunitoSans',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.light,
              elevation: 0,
            )),
        home: const SplashScreen(),
      ),
    );
  }
}

MaterialColor primarySwatch = const MaterialColor(0xff2C363F, <int, Color>{
  50: Color.fromRGBO(5, 102, 118, .1),
  100: Color.fromRGBO(5, 102, 118, .2),
  200: Color.fromRGBO(5, 102, 118, .3),
  300: Color.fromRGBO(5, 102, 118, .4),
  400: Color.fromRGBO(5, 102, 118, .5),
  500: Color.fromRGBO(5, 102, 118, .6),
  600: Color.fromRGBO(5, 102, 118, .7),
  700: Color.fromRGBO(5, 102, 118, .8),
  800: Color.fromRGBO(5, 102, 118, .9),
  900: Color.fromRGBO(5, 102, 118, 1),
});
