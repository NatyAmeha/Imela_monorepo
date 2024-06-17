
enum LogLevel { DEBUG, INFO, WARNING, ERROR, FATAL }

class LogData {
  final String? source;
  final String? message;
  final LogLevel logLevel;
  final DateTime? date;
  final dynamic error;
  final StackTrace? stackTrace;

  LogData({this.source, this.message, required this.logLevel, this.error, this.stackTrace, this.date});
}
