import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';

import 'common_widgets/time_buttons.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final ValueNotifier<int> _hours = ValueNotifier<int>(0);
  final ValueNotifier<int> _minutes = ValueNotifier<int>(0);
  final ValueNotifier<int> _seconds = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isRunning = ValueNotifier<bool>(false);
  Timer? _timer;

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    _seconds.dispose();
    _isRunning.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_hours.value == 0 && _minutes.value == 0 && _seconds.value == 0) {
      _showToast("❌🕒 Please Provide Valid Time 🕒❌");
      return;
    }

    if (_timer != null) {
      _timer!.cancel();
    }

    int totalTime = (_hours.value * 3600) + (_minutes.value * 60) + (_seconds.value);
    _isRunning.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalTime > 0) {
        totalTime--;
        _hours.value = totalTime ~/ 3600;
        _minutes.value = (totalTime % 3600) ~/ 60;
        _seconds.value = totalTime % 60;
      } else {
        _timer!.cancel();
        _showToast("✅ Time's up! ✅");
        _hours.value = 0;
        _minutes.value = 0;
        _seconds.value = 0;
        _isRunning.value = false;
        setState(() {});
      }
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _isRunning.value = false;
    _hours.value = 0;
    _minutes.value = 0;
    _seconds.value = 0;
  }

  void _showToast(String message) {
    debugPrint("MESSAGE:---- $message");
    InteractiveToast.slide(
      context,
      title: Text(message),
      trailing: const FlutterLogo(),
      onTapped: () {
        InteractiveToast.closeAllToast;
      },
      toastSetting: const SlidingToastSetting(
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: ToastPosition.top,
        toastAlignment: Alignment.topCenter,
        progressBarHeight: 4,
      ),
      toastStyle: const ToastStyle(
        glassBlur: 4,
        backgroundColorOpacity: .3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Timer App'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _timerWidget(),
            const SizedBox(height: 20.0),
            _startStopButton(),
          ],
        ),
      ),
    );
  }

  Widget _timerWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _hours,
          builder: (context, value, child) {
            return TimeButtons(
              upButtonTap: _isRunning.value
                  ? null
                  : () {
                      _hours.value = (_hours.value + 1) % 24;
                    },
              text: value.toString().padLeft(2, '0'),
              downButtonTap: _isRunning.value
                  ? null
                  : () {
                      _hours.value = (_hours.value - 1) < 0 ? 23 : _hours.value - 1;
                    },
            );
          },
        ),
        const SizedBox(width: 10.0),
        ValueListenableBuilder<int>(
          valueListenable: _minutes,
          builder: (context, value, child) {
            return TimeButtons(
              upButtonTap: _isRunning.value
                  ? null
                  : () {
                      _minutes.value = (_minutes.value + 1) % 60;
                    },
              text: value.toString().padLeft(2, '0'),
              downButtonTap: _isRunning.value
                  ? null
                  : () {
                      _minutes.value = (_minutes.value - 1) < 0 ? 59 : _minutes.value - 1;
                    },
            );
          },
        ),
        const SizedBox(width: 10.0),
        ValueListenableBuilder<int>(
          valueListenable: _seconds,
          builder: (context, value, child) {
            return TimeButtons(
              upButtonTap: _isRunning.value
                  ? null
                  : () {
                      _seconds.value = (_seconds.value + 1) % 60;
                    },
              text: value.toString().padLeft(2, '0'),
              downButtonTap: _isRunning.value
                  ? null
                  : () {
                      _seconds.value = (_seconds.value - 1) < 0 ? 59 : _seconds.value - 1;
                    },
            );
          },
        ),
      ],
    );
  }

  Widget _startStopButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isRunning,
      builder: (context, isRunning, child) {
        if (isRunning) {
          return CupertinoButton(
            color: CupertinoColors.destructiveRed,
            onPressed: _stopTimer,
            child: const Text('Stop Timer'),
          );
        }
        return CupertinoButton.filled(
          onPressed: isRunning ? null : _startTimer,
          child: const Text('Start Timer'),
        );
      },
    );
  }
}
