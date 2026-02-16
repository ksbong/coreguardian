import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/game_manager.dart';
import '../features/simulation/logic/reactor_provider.dart';

class GameTopHud extends StatelessWidget {
  const GameTopHud({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer2를 사용하여 GameManger와 ReactorProvider 둘 다 구독
    return Consumer2<GameManager, ReactorProvider>(
      builder: (context, game, reactor, child) {
        final state = reactor.state;

        // 온도에 따른 위험 색상 결정
        Color tempColor = Colors.cyanAccent;
        if (state.temperature > 800) tempColor = Colors.orangeAccent;
        if (state.temperature > 1000) tempColor = Colors.redAccent;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .9),
                Colors.black.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. 좌측: 날짜 및 시간
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DAY ${game.day}",
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.timeString,
                          style: GoogleFonts.shareTechMono(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 2. 중앙: 시스템 상태 (경고 메시지)
                _buildSystemStatus(state),

                // 3. 우측: 핵심 물리 수치 (온도, 압력, 출력)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatRow(
                      "TEMP",
                      "${state.temperature.toStringAsFixed(0)}°C",
                      tempColor,
                    ),
                    const SizedBox(height: 4),
                    _buildStatRow(
                      "PRES",
                      "${state.pressure.toStringAsFixed(2)} MPa",
                      Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    _buildStatRow(
                      "PWR",
                      "${state.electricalOutput.toStringAsFixed(0)} MWe",
                      Colors.amberAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 시스템 상태 텍스트 위젯
  Widget _buildSystemStatus(ReactorState state) {
    String status = "NORMAL";
    Color color = Colors.greenAccent;
    IconData icon = Icons.check_circle_outline;

    if (state.isMeltdown) {
      status = "MELTDOWN";
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
    } else if (state.isScrammed) {
      status = "SCRAMMED";
      color = Colors.orange;
      icon = Icons.error_outline;
    } else if (state.temperature > 1000) {
      status = "CRITICAL";
      color = Colors.redAccent;
      icon = Icons.gpp_bad;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            status,
            style: GoogleFonts.oswald(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // 우측 수치 표시용 헬퍼
  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80, // 고정 폭으로 숫자 떨림 방지
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.shareTechMono(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
