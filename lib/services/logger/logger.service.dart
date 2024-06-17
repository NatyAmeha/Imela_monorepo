import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:melegna_customer/services/logger/log.model.dart';
import 'package:melegna_customer/services/logger/log_output.service.dart';

abstract class ILogService {
  List<LogData> errorLogs = [];
  void log(LogData data);
}


@Singleton(as: ILogService)
@Named(AppLogService.injectName)
class AppLogService implements ILogService {
  static const injectName = 'AppLogService';
  // final ILogOutput? fileLogOutput;
  static Logger? _logger;

  

  @override
  List<LogData> errorLogs = [];

   void batchLogs(LogData logs){
    errorLogs.add(logs);
  }

  AppLogService();

  Logger get getLoggerInstance {
    if (_logger != null) {
      return _logger!;
    } else {
      _logger = Logger(printer: AppLogFormat() );
      return _logger!;
    }
  }

  @override
  void log(LogData logData) {
    switch (logData.logLevel) {
      case LogLevel.DEBUG:
        getLoggerInstance.d(logData.message);
        break;
      case LogLevel.INFO:
        getLoggerInstance.i(logData.message);
        break;
      case LogLevel.WARNING:
        getLoggerInstance.w(logData.message);
        break;
      case LogLevel.ERROR:
        getLoggerInstance.log(Level.error, logData.message, error: logData.error);
        batchLogs(logData);
        break;
      case LogLevel.FATAL:
        getLoggerInstance.log(Level.fatal, logData.message, error: logData.error, stackTrace: logData.stackTrace);
        batchLogs(logData);
        break;

      default:
        getLoggerInstance.d(logData.message);
    }
  }
}