import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:melegna_customer/services/logger/log.model.dart';

abstract class ILogOutput extends LogOutput {}

@Injectable(as: ILogOutput)
@Named(FileLogOutput.injectName)
class FileLogOutput implements ILogOutput {
  static const injectName = 'FileLogOutput';
  @override
  void output(OutputEvent data) {
    // TODO: implement output
  }

  
  
  @override
  Future<void> destroy() {
    // TODO: implement destroy
    throw UnimplementedError();
  }
  
  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }
}


@injectable
class AppLogFormat extends LogPrinter {
   String? className;
  AppLogFormat();

  void setClassName(String name) {
    className = name;
  }

  static final Map<LogLevel, String> levelColors = {
    LogLevel.DEBUG: '\x1B[34m',  // blue
    LogLevel.INFO: '\x1B[32m', // green
    LogLevel.WARNING: '\x1B[33m', // yellow
    LogLevel.ERROR: '\x1B[31m', // red
    LogLevel.FATAL: '\x1B[35m' // magenta
  };

  @override
  List<String> log(LogEvent event) {
    final color = levelColors[event.level]!;
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level]!;
    final message = event.message as LogData;
    final time = DateTime.now().toIso8601String();

    return ['$color$time  $emoji $message'];
  }
}
