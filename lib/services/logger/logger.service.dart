import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:melegna_customer/services/logger/log.model.dart';
import 'package:melegna_customer/services/logger/log_output.service.dart';

abstract class ILogService {
  void log(LogData data);
}

@Named(AppLogService.injectName)
@Injectable(as: ILogService)
class AppLogService implements ILogService {
  static const injectName = 'AppLogService';
  final ILogOutput? logOutput;
  static Logger? _logger;

  const AppLogService({this.logOutput});
  Logger get getLoggerInstance {
    if (_logger != null) {
      return _logger!;
    } else {
      _logger = Logger(printer: AppLogFormat(), output: logOutput);
      return _logger!;
    }
  }

  @override
  void log(LogData data) {
    switch (data.logLevel) {
      case LogLevel.DEBUG:
        getLoggerInstance.d(data.message);
        break;
      case LogLevel.INFO:
        getLoggerInstance.i(data.message);
        break;
      case LogLevel.WARNING:
        getLoggerInstance.w(data.message);
        break;
      case LogLevel.ERROR:
        getLoggerInstance.log(Level.error, data.message, error: data.error);
        break;
      case LogLevel.FATAL:
        getLoggerInstance.log(Level.error, data.message, error: data.error, stackTrace: data.stackTrace);
        break;

      default:
        getLoggerInstance.d(data.message);
    }
  }
}
