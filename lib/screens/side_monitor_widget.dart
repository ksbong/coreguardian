import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/reactor_provider.dart';

class SideMonitorWidget extends StatefulWidget {
  const SideMonitorWidget({super.key});

  @override
  State<SideMonitorWidget> createState() => _SideMonitorWidgetState();
}

class _SideMonitorWidgetState extends State<SideMonitorWidget> {
  // 📈 데이터 버퍼 (최근 50개의 온도 데이터를 저장)
  final List<double> _tempHistory = List.filled(50, 0.0, growable: true);

  // 갱신 주기를 조절하기 위한 변수 (매 프레임마다 리스트가 너무 빨리 차는 것 방지)
  // ignore: unused_field
  final int _tickCounter = 0;

  @override
  Widget build(BuildContext context) {
    // ReactorProvider를 구독하여 매 틱마다 데이터를 받아옴
    final reactor = context.watch<ReactorProvider>();
    final currentTemp = reactor.state.temperature;

    // 데이터 갱신 로직 (UI 빌드될 때마다 실행됨)
    // 실제로는 별도 Timer나 Stream을 쓰는 게 정석이지만,
    // 여기선 Provider notify에 맞춰 심플하게 구현
    _updateHistory(currentTemp);

    return Container(
      width: 220, // 모니터 너비
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115).withValues(alpha: 0.9),
        border: Border.all(
          color: currentTemp > 1000
              ? Colors.redAccent
              : Colors.cyanAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: (currentTemp > 1000 ? Colors.red : Colors.cyanAccent)
                .withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (타이틀 + 현재 값)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CORE TEMP",
                style: GoogleFonts.oswald(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                "${currentTemp.toStringAsFixed(0)}°C",
                style: GoogleFonts.shareTechMono(
                  color: _getAlertColor(currentTemp),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. 오실로스코프 그래프 영역
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: ChartPainter(
                dataPoints: _tempHistory,
                maxVal: 1500.0, // 그래프 Y축 최대값 (멜트다운 기준보다 조금 높게)
                lineColor: _getAlertColor(currentTemp),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3. 상태 메시지 (간단 요약)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              currentTemp > 1200 ? "⚠️ MELTDOWN IMMINENT" : "MONITORING ACTIVE",
              style: GoogleFonts.shareTechMono(
                color: currentTemp > 1200 ? Colors.red : Colors.cyanAccent,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateHistory(double newTemp) {
    // 리스트가 꽉 차면 가장 오래된 데이터 삭제 (FIFO)
    if (_tempHistory.length >= 50) {
      _tempHistory.removeAt(0);
    }
    _tempHistory.add(newTemp);
  }

  Color _getAlertColor(double temp) {
    if (temp > 1000) return Colors.redAccent;
    if (temp > 800) return Colors.orangeAccent;
    return Colors.cyanAccent;
  }
}

// 🎨 커스텀 페인터 (실제 그래프 그리는 화가)
class ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double maxVal;
  final Color lineColor;

  ChartPainter({
    required this.dataPoints,
    required this.maxVal,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 배경 그리드 그리기
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    // 가로선 4개
    for (int i = 1; i < 4; i++) {
      double dy = size.height * (i / 4);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }
    // 세로선 5개
    for (int i = 1; i < 5; i++) {
      double dx = size.width * (i / 5);
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }

    if (dataPoints.isEmpty) return;

    // 2. 데이터 라인 패스 생성
    final path = Path();
    final double stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      // 값을 Y좌표로 변환 (0이 아래쪽, maxVal이 위쪽이 되도록 반전)
      // clamp로 그래프 밖으로 튀어나가는 것 방지
      double normalizedY = (dataPoints[i] / maxVal).clamp(0.0, 1.0);
      double dy = size.height - (normalizedY * size.height);
      double dx = i * stepX;

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    // 3. 라인 그리기 (네온 효과)
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 그림자(Glow) 효과 추가
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withValues(alpha: 0.5)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawPath(path, linePaint);

    // 4. 그라데이션 채우기 (선 아래쪽을 은은하게 채움)
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradient = ui.Gradient.linear(Offset(0, 0), Offset(0, size.height), [
      lineColor.withValues(alpha: 0.3),
      lineColor.withValues(alpha: 0.0),
    ]);

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill,
    );

    // 5. 현재 위치 표시 점 (Scan Point)
    final lastX = size.width;
    final lastData = (dataPoints.last / maxVal).clamp(0.0, 1.0);
    final lastY = size.height - (lastData * size.height);

    canvas.drawCircle(Offset(lastX, lastY), 4.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
