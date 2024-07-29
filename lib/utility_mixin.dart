import 'package:flutter/material.dart';

mixin Utility {
  Widget appLogo({double? height, double? width, double? fontSize}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: height ?? 60,
      width: width ?? 60,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Image.asset("asset/logo.png"),
      ),
    );
  }

  SizedBox heightBox5() => const SizedBox(height: 5);

  SizedBox heightBox10() => const SizedBox(height: 10);

  SizedBox heightBox20() => const SizedBox(height: 20);

  SizedBox heightBox30() => const SizedBox(height: 30);

  SizedBox heightBox40() => const SizedBox(height: 40);

  SizedBox heightBox50() => const SizedBox(height: 50);

  SizedBox widthBox5() => const SizedBox(width: 5);

  SizedBox widthBox10() => const SizedBox(width: 10);

  SizedBox widthBox16() => const SizedBox(width: 16);

  SizedBox widthBox20() => const SizedBox(width: 20);

  SizedBox widthBox30() => const SizedBox(width: 30);
}
