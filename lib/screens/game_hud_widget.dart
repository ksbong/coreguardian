import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/game_manager.dart';
import '../features/simulation/logic/reactor_provider.dart';

class GameTopHud extends StatelessWidget {
  const GameTopHud({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameManager>();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 왼쪽: 날짜/시간
            _buildInfoChip(
              Icons.calendar_today,
              "Day ${game.day}  ${game.timeString}",
              Colors.white,
            ),

            // 오른쪽: 설정/일시정지
            Row(
              children: [
                _buildInfoChip(
                  Icons.attach_money,
                  "1,250K",
                  Colors.greenAccent,
                ), // 예시: 자금
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    game.isPaused
                        ? Icons.play_circle_fill
                        : Icons.pause_circle_filled,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    game.isPaused ? game.startGame() : game.pauseGame();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class SideMonitorWidget extends StatelessWidget {
  const SideMonitorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final reactor = context.watch<ReactorProvider>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildSideGraph(
          "Pressure",
          reactor.pressure / 20.0,
          Colors.cyan,
        ), // 20MPa 기준
        const SizedBox(height: 8),
        _buildSideGraph(
          "Core Heat",
          reactor.temperature / 1500.0,
          Colors.redAccent,
        ), // 1500도 기준
      ],
    );
  }

  Widget _buildSideGraph(String label, double percent, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        border: Border(right: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
