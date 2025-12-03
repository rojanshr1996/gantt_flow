import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Color? safeAreaColor;
  final Color backgroundColor;
  final PreferredSizeWidget? appBar;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget body;
  final bool safeArea;

  const BackgroundScaffold({
    Key? key,
    this.appBar,
    required this.body,
    required this.backgroundColor,
    this.safeAreaColor,
    this.scaffoldKey,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.safeArea = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: safeAreaColor ?? backgroundColor,
      child: SafeArea(
        left: safeArea ? true : false,
        top: safeArea ? true : false,
        right: safeArea ? true : false,
        bottom: safeArea ? true : false,
        child: Scaffold(
          key: scaffoldKey,
          drawer: drawer,
          backgroundColor: backgroundColor,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          body: body,
        ),
      ),
    );
  }
}
