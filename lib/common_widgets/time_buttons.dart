import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeButtons extends StatelessWidget {
  const TimeButtons({
    super.key,
    required this.upButtonTap,
    required this.text,
    required this.downButtonTap,
  });

  final void Function()? upButtonTap;
  final String text;
  final void Function()? downButtonTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          CupertinoButton(
            onPressed: upButtonTap,
            child: const Icon(Icons.arrow_drop_up_rounded),
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 32.0),
          ),
          CupertinoButton(
            onPressed: downButtonTap,
            child: const Icon(Icons.arrow_drop_down_rounded),
          ),
        ],
      ),
    );
  }
}
