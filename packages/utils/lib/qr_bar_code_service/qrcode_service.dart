import 'package:imela_utils/qr_bar_code_service/qr_response.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';

abstract class IQRCodeService {
  /// Encodes data into a QR Code format
  Future<QRCodeResponse> getQRCodeUI<T>(T data, {double? size});

  /// Decodes data from a QR Code
  Future<QRCodeResponse> decodeData(String qrCodeData);
}

// utils/qr_code_service_impl.dart

@Injectable(as: IQRCodeService)
@Named(QRCodeService.injectName)
class QRCodeService extends IQRCodeService {
  static const injectName = 'QRCodeServiceImpl';
  @override
  Future<QRCodeResponse> getQRCodeUI<T>(T data, {double? size}) async {
    try {
      String encodedData = data.toString();

      final qrCode = QrImageView(data: encodedData, size: size ?? 200.0);

      // Return the QR code widget and encoded data in a response
      return QRCodeResponse(success: true, qrCodeWidget: qrCode, data: encodedData);
    } catch (e) {
      return QRCodeResponse(success: false, errorMessage: e.toString());
    }
  }

  @override
  Future<QRCodeResponse> decodeData(String qrCodeData) async {
    try {
      // For decoding, you may use additional packages or implement your own logic
      return QRCodeResponse(success: true, data: qrCodeData);
    } catch (e) {
      return QRCodeResponse(success: false, errorMessage: e.toString());
    }
  }
}
