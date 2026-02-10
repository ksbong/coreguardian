import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_manager.dart';
import '../logic/reactor_provider.dart';

class StatusOverlayWidget extends StatelessWidget {
  const StatusOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 1초마다 갱신되는 GameManager와 실시간 물리 엔진 상태 구독
    final game = context.watch<GameManager>();
    final reactorState = context.watch<ReactorProvider>().state;

    // 위험도에 따른 색상 변경 (800도 이상 위험, 500도 이상 주의)
    Color statusColor = Colors.greenAccent;
    if (reactorState.temperature > 800) {
      statusColor = Colors.redAccent;
    } else if (reactorState.temperature > 500) {
      statusColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181B21).withValues(alpha: .95), // 반투명 배경
        border: Border(bottom: BorderSide(color: statusColor, width: 2)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: .3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // [왼쪽] 날짜 및 시간 (D-Day 카운트다운 느낌)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "DAY ${game.day} / ${GameManager.maxDays}",
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  game.timeString,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // [중앙] 핵심 지표 3대장 (온도, 압력, 출력)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    "CORE TEMP",
                    "${reactorState.temperature.toStringAsFixed(1)}°C",
                    statusColor,
                  ),
                  _buildMetric(
                    "PRESSURE",
                    "${reactorState.pressure.toStringAsFixed(2)} MPa",
                    Colors.cyanAccent,
                  ),
                  // 출력은 MW 단위 (전력)
                  _buildMetric(
                    "OUTPUT",
                    "${reactorState.electricalOutput.toStringAsFixed(0)} MWe",
                    Colors.yellowAccent,
                  ),
                ],
              ),
            ),

            // [오른쪽] 일시정지/재생 컨트롤
            IconButton(
              icon: Icon(
                game.isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              onPressed: () {
                if (game.isPaused) {
                  game.startGame();
                } else {
                  game.pauseGame();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
