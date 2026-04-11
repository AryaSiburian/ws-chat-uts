import 'package:flutter/material.dart';
import '../config/app_sizes.dart';

class ResponsiveHelper {
  ResponsiveHelper._();
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < AppSizes.phoneBreakpoint;
  static double bubbleMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return isPhone(context)
        ? w * AppSizes.bubbleRatioPhone
        : w * AppSizes.bubbleRatioWeb;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext) phone;
  final Widget Function(BuildContext) web;
  const ResponsiveLayout({super.key, required this.phone, required this.web});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppSizes.phoneBreakpoint) {
          return phone(context);
        }
        return web(context);
      },
    );
  }
}
