import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:lawyerapp/page/Mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward().then((_) {
      // เมื่อ Animation ทำงานเสร็จสิ้น
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Mainscreen(data:'ok',screen: 0,)),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // ยกเลิก AnimationController เมื่อ State ถูก dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Scaffold(
          body: Center(
            child: CustomPaint(
              painter: MyCustomPainter(_animation.value),
              child: SizedBox(
                width: 300,
                height: 300,
                child: Center(
                  child: Image.asset('images/newbackground.png',
                      width: 100,
                      scale: 1), // เปลี่ยนเป็นที่อยู่ของรูปภาพของคุณ
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double animationValue;

  MyCustomPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double progress = (2 * math.pi) * animationValue;

    // กำหนด TweenSequence สำหรับการเปลี่ยนแปลงสี
    final TweenSequence<Color?> tweenSequence = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.blue, end: Colors.green),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.green, end: Colors.blue),
        weight: 50,
      ),
    ]);

    paint.color = tweenSequence.transform(animationValue)!;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

