import 'package:flutter/material.dart';
import 'package:gantt_mobile/widgets/components/simple_circular_loader.dart';

class LazyLoadingCircularLoader extends StatelessWidget {
  final bool isScrolling;
  final EdgeInsetsGeometry padding;

  const LazyLoadingCircularLoader({Key? key, required this.isScrolling, this.padding = const EdgeInsets.all(8.0)})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Opacity(
          opacity: isScrolling ? 1.0 : 00,
          child: const SimpleCircularLoader(),
        ),
      ),
    );
  }
}
