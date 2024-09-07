import 'package:flutter/material.dart';
import 'package:slide_countdown/slide_countdown.dart';

class CountdownTimer extends StatelessWidget {
  final Duration duration;
  final TextStyle? textStyle;
  final String? separator;
  final Color backgroundColor;
  final double borderRadius;
  final bool shouldShowHours;
  final bool shouldShowMinutes;
  final bool shouldShowSeconds;
  Function? onDone;
  Function(Duration)? onTick;

  late final StreamDuration streamDuration;

  CountdownTimer({
    super.key,
    required this.duration,
    this.textStyle,
    this.separator,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0,
    this.shouldShowHours = true,
    this.shouldShowMinutes = true,
    this.shouldShowSeconds = true,
  }) {
    streamDuration = StreamDuration(config: StreamDurationConfig(countDownConfig: CountDownConfig(duration: duration)));
  }

  @override
  Widget build(BuildContext context) {
    return SlideCountdown(
      duration: duration,
      streamDuration: streamDuration,
      style: textStyle ?? const TextStyle(fontSize: 20, color: Colors.white),
      separator: separator ?? ':',
      separatorStyle: textStyle ?? const TextStyle(fontSize: 20, color: Colors.white),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      shouldShowHours: (p0) => shouldShowHours,
      shouldShowMinutes: (p0) => shouldShowMinutes,
      shouldShowSeconds: (p0) => shouldShowSeconds,
      onDone: () {
       onDone?.call();
      },
      onChanged: (value) {
        onTick?.call(value);
      },
    );
  }
}
