import 'package:flutter/material.dart';

class AppNavigationDestination {
  final String name;
  final IconData icon;
  final Widget screen;
  final Function()? onTap;

  const AppNavigationDestination({
    required this.name,
    required this.icon,
    required this.screen,
    this.onTap,
  });
}
