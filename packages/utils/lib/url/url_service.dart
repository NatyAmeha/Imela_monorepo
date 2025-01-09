import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class IUrlService {
  Future<bool> launchPhoneCall(String phoneNumber);
  Future<bool> launchEmail(String email, {String? subject, String? body});
  Future<bool> launchWebUrl(String url);
  Future<bool> launchSms(String phoneNumber, {String? message});
  Future<bool> launchMap(double latitude, double longitude, {String? label});

  Future<bool> copyToClipboard(String text);
}

@Injectable(as: IUrlService)
@Named(UrlService.injectName)
class UrlService implements IUrlService {
  static const injectName = 'UrlService';

  UrlService();

  @override
  Future<bool> launchPhoneCall(String phoneNumber) async {
    final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    return await launchUrl(phoneUri);
  }

  @override
  Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    final result = await launchUrl(emailUri);
    return result;
  }

  @override
  Future<bool> launchWebUrl(String url) async {
    final webUri = Uri.parse(url);
    final result = await launchUrl(webUri, mode: LaunchMode.externalApplication);
    return result;
  }

  @override
  Future<bool> launchSms(String phoneNumber, {String? message}) async {
    final smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: message != null ? {'body': message} : null,
    );
    final result = await launchUrl(smsUri);
    return result;
  }

  @override
  Future<bool> launchMap(double latitude, double longitude, {String? label}) async {
    final mapUri = Uri(
      scheme: 'geo',
      path: '$latitude,$longitude',
      queryParameters: label != null ? {'q': label} : null,
    );
    final result = await launchUrl(mapUri);
    return result;
  }

  @override
  Future<bool> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  }
}
