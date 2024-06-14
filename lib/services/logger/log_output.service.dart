import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

abstract class ILogOutput extends LogOutput {}

@Named(FileLogOutput.injectName)
@Injectable(as: ILogOutput)
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

class AppLogFormat extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return ['\nlevel : ${event.level} - ${event.time}\n', 'message : ${event.message}\n', event.error != null ? 'error : ${event.error}\n' : "", event.stackTrace != null ? 'stack : ${event.stackTrace}\n' : '', '-----------------------------------------\n\n'];
  }
}
