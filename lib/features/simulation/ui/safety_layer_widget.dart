import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyLayerWidget extends StatelessWidget {
  final double fuelHealth; // 펠렛 건전성 (0.0 ~ 1.0)
  final double claddingHealth; // 피복관 건전성
  final double vesselHealth; // 압력용기 건전성
  final double containmentHealth; // 격납건물 건전성

  const SafetyLayerWidget({
    super.key,
    required this.fuelHealth,
    required this.claddingHealth,
    required this.vesselHealth,
    required this.containmentHealth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "심층 방어 상태 (Defense in Depth)",
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(
            painter: BarrierPainter(
              fuelHealth: fuelHealth,
              claddingHealth: claddingHealth,
              vesselHealth: vesselHealth,
              containmentHealth: containmentHealth,
            ),
          ),
        ),
      ],
    );
  }
}

class BarrierPainter extends CustomPainter {
  final double fuelHealth;
  final double claddingHealth;
  final double vesselHealth;
  final double containmentHealth;

  BarrierPainter({
    required this.fuelHealth,
    required this.claddingHealth,
    required this.vesselHealth,
    required this.containmentHealth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 각 방벽별 색상 계산 (건전성이 낮을수록 빨간색)
    Color getColor(double health) =>
        Color.lerp(Colors.red, const Color(0xFF00FFCC), health)!;

    // 4. 격납건물 (가장 바깥)
    _drawLayer(
      canvas,
      center,
      140,
      getColor(containmentHealth),
      "격납건물",
      containmentHealth,
    );

    // 3. 원자로 압력용기
    _drawLayer(
      canvas,
      center,
      100,
      getColor(vesselHealth),
      "압력용기",
      vesselHealth,
    );

    // 2. 피복관
    _drawLayer(
      canvas,
      center,
      65,
      getColor(claddingHealth),
      "피복관",
      claddingHealth,
    );

    // 1. 연료 펠렛 (가장 안쪽)
    Paint paint = Paint()
      ..color = getColor(fuelHealth)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 30, paint);

    // 텍스트 (펠렛)
    _drawText(canvas, center, "Core", Colors.black);
  }

  void _drawLayer(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    String label,
    double health,
  ) {
    Paint paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // 배경 원 (어두운 색)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20,
    );

    // 상태 게이지 (건전성 만큼만 채워짐)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * health,
      false,
      paint,
    );

    // 테두리
    canvas.drawCircle(
      center,
      radius + 10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawText(Canvas canvas, Offset center, String text, Color color) {
    TextSpan span = TextSpan(
      style: GoogleFonts.orbitron(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
