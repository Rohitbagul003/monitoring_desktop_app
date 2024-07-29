import 'package:camera/camera.dart';
import 'package:desktop_timer/utility_mixin.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class CameraScreenShotScreen extends StatefulWidget {
  const CameraScreenShotScreen({
    super.key,
    required this.screenshotController,
    required this.cameraController,
    required this.isCameraInitialized,
  });
  final ScreenshotController screenshotController;
  final CameraController? cameraController;
  final bool isCameraInitialized;
  @override
  State<CameraScreenShotScreen> createState() => _CameraScreenShotScreenState();
}

class _CameraScreenShotScreenState extends State<CameraScreenShotScreen> with Utility {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: widget.screenshotController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'This is the area to be captured in the screenshot.',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            heightBox5(),
            widget.isCameraInitialized
                ? SizedBox(
                    width: 180,
                    height: 120,
                    child: CameraPreview(widget.cameraController!),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
