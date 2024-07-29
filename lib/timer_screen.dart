import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:desktop_timer/camera_screenshot_screen.dart';
import 'package:desktop_timer/utility_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:screenshot/screenshot.dart';

import 'common_widgets/time_buttons.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with Utility {
  final ValueNotifier<int> _hours = ValueNotifier<int>(0);
  final ValueNotifier<int> _minutes = ValueNotifier<int>(0);
  final ValueNotifier<int> _seconds = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isRunning = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _loadingCamera = ValueNotifier<bool>(false);
  ScreenshotController screenshotController = ScreenshotController();
  CameraController? cameraController;
  Timer? _timer;
  List<CameraDescription>? cameras = [];
  bool isCameraInitialized = false;

  final headshot = ValueNotifier<List<XFile?>>([]);
  final screenshot = ValueNotifier<List<Uint8List?>>([]);
  final _setState = ValueNotifier<bool>(false);

  @override
  void dispose() {
    cameraController?.dispose();
    _loadingCamera.dispose();
    _hours.dispose();
    _minutes.dispose();
    _seconds.dispose();
    _isRunning.dispose();
    _timer?.cancel();

    headshot.dispose();
    screenshot.dispose();
    _setState.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) async {
      cameras = await availableCameras();
      await initializeCamera();
    });
    super.initState();
  }

  void _startTimer() {
    if (_hours.value == 0 && _minutes.value == 0 && _seconds.value == 0) {
      _showToast("❌🕒 Please Provide Valid Time 🕒❌");
      return;
    }

    if (_seconds.value <= 2) {
      _showToast("❌🕒 Can't Start Timer Below 2 Seconds 🕒❌");
      return;
    }

    if (_timer != null) {
      _timer!.cancel();
    }

    int totalTime = (_hours.value * 3600) + (_minutes.value * 60) + (_seconds.value);
    _isRunning.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (totalTime > 0) {
        totalTime--;
        _hours.value = totalTime ~/ 3600;
        _minutes.value = (totalTime % 3600) ~/ 60;
        _seconds.value = totalTime % 60;

        if (totalTime % 2 == 0) await captureScreenshotAndHeadshot();
      } else {
        _timer!.cancel();
        _showToast("✅ Time's up! ✅");
        _hours.value = 0;
        _minutes.value = 0;
        _seconds.value = 0;
        _isRunning.value = false;
        await captureScreenshotAndHeadshot();
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

  Future<void> initializeCamera() async {
    try {
      _loadingCamera.value = true;

      if (cameras != null && cameras!.isNotEmpty) {
        cameraController = CameraController(cameras![0], ResolutionPreset.high);

        await cameraController?.initialize();
        isCameraInitialized = true;
        debugPrint("Camera is initialized !!!");
      } else {
        if (!context.mounted) return;
        await Future.delayed(const Duration(milliseconds: 100));

        _showToast("Unable to find camera, headshots would be available");
      }
    } catch (err, stk) {
      debugPrint("Catch Error On initialize camera $err, $stk");
    }

    _loadingCamera.value = false;
  }

  Future<void> captureScreenshotAndHeadshot() async {
    try {
      // Capture Screenshot
      final screenshotImage = await screenshotController.capture();

      // Capture Headshot
      final headshotImage = await cameraController?.takePicture();

      screenshot.value.add(screenshotImage);
      headshot.value.add(headshotImage);
      _setState.value = !_setState.value;
    } catch (e, stk) {
      debugPrint("Error capturing images: $e, $stk");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Timer App'),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _loadingCamera,
        builder: (context, loading, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!loading)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CameraScreenShotScreen(
                        cameraController: cameraController,
                        screenshotController: screenshotController,
                        isCameraInitialized: isCameraInitialized,
                      ),
                      heightBox10(),
                    ],
                  ),
                ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _timerWidget(),
                      heightBox20(),
                      _startStopButton(),
                      heightBox20(),
                      _screenShotAndHeadShotWidget(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _screenShotAndHeadShotWidget() {
    return Material(
      child: ValueListenableBuilder(
          valueListenable: _setState,
          builder: (context, setState, _) {
            return ValueListenableBuilder(
              valueListenable: screenshot,
              builder: (context, _screenshot, _) {
                return ValueListenableBuilder(
                  valueListenable: headshot,
                  builder: (context, _headshot, _) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _screenshot.isNotEmpty
                                    ? SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          physics: const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _screenshot.length,
                                          itemBuilder: (context, index) {
                                            final img = _screenshot[index];
                                            return InkWell(
                                              onTap: () async {
                                                await showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      content: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey),
                                                        ),
                                                        child: Image.memory(
                                                          img,
                                                          width: 900,
                                                          height: 550,
                                                          fit: BoxFit.fitWidth,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text("Close"),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black12),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Image.memory(img!, width: 180, height: 120),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(),
                                heightBox10(),
                                _headshot.isNotEmpty
                                    ? SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          physics: const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _headshot.length,
                                          itemBuilder: (context, index) {
                                            final img = _headshot[index];
                                            return InkWell(
                                              onTap: () async {
                                                await showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      content: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey),
                                                        ),
                                                        child: Image.file(
                                                          File(img.path),
                                                          width: 900,
                                                          height: 550,
                                                          fit: BoxFit.fitHeight,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text("Close"),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black12),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Image.file(
                                                  File(img!.path),
                                                  width: 180,
                                                  height: 120,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            if (_screenshot.isNotEmpty && _headshot.isNotEmpty)
                              Row(
                                children: [
                                  widthBox10(),
                                  InkWell(
                                    onTap: () {
                                      screenshot.value.clear();
                                      headshot.value.clear();
                                      _setState.value = !_setState.value;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.clear, color: Colors.white),
                                          heightBox10(),
                                          const Text("CLEAR", style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
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
