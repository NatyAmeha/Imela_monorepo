import 'package:flutter/cupertino.dart';

class QRCodeResponse {
  final bool success;
  final String? errorMessage;
  final String? data;
  final Widget? qrCodeWidget;

  QRCodeResponse({
    required this.success,
    this.errorMessage,
    this.data,
    this.qrCodeWidget,
  });
}
