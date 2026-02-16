import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/game_manager.dart';
import 'reactor_3d_view.dart';
import 'side_monitor_widget.dart'; // 우측 그래프 모니터
import 'control_panel_widget.dart'; // 👈 [핵심] 이걸 import 해야 함!

class MainGameScreen extends StatelessWidget {
  const MainGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 배경: 3D 원자로 뷰
          const Positioned.fill(child: Reactor3DView(isInteractive: true)),

          // 2. 전면 HUD 레이아웃
          SafeArea(
            child: Column(
              children: [
                // A. 상단 상태바 (시간, 날짜)
                _buildTopStatusBar(),

                // B. 중간 여백 (여기에 3D 모델이 보임)
                const Spacer(),

                // C. 하단 컨트롤 패널 (새로 만든 위젯 연결!)
                // 기존의 _buildBottomControlPanel() 함수 호출을 지우고
                // 깔끔하게 위젯 클래스를 직접 사용합니다.
                const Positioned(
                  left: 0,
                  top: 100,
                  bottom: 50,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ControlPanelWidget(),
                  ),
                ),
              ],
            ),
          ),

          // 3. 우측 사이드 모니터 (오실로스코프 그래프)
          // 화면 오른쪽에 둥둥 떠있게 배치
          const Positioned(top: 120, right: 20, child: SideMonitorWidget()),
        ],
      ),
    );
  }

  // 🕒 상단 상태바 위젯 (간단해서 여기에 남겨둠)
  Widget _buildTopStatusBar() {
    return Consumer<GameManager>(
      builder: (context, game, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(
                  alpha: 0.8,
                ), // withValues 대신 호환성 좋은 withOpacity
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 날짜 & 시간
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DAY ${game.day}",
                    style: GoogleFonts.oswald(
                      color: Colors.cyanAccent,
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
                      const SizedBox(width: 5),
                      Text(
                        game.timeString,
                        style: GoogleFonts.shareTechMono(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 시스템 상태 요약 태그
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: game.isGameOver ? Colors.red : Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black54,
                ),
                child: Text(
                  game.isGameOver ? "CRITICAL FAILURE" : "SYSTEM NORMAL",
                  style: GoogleFonts.shareTechMono(
                    color: game.isGameOver ? Colors.red : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
