import 'package:flutter/material.dart';

class DashboardDestination{
  final String name;
  final IconData icon;
  final Widget screen;
  final Function()? onTap;

  const DashboardDestination({required this.name, required this.icon, required this.screen, this.onTap});
}