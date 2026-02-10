import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../features/simulation/logic/game_manager.dart';
// import '../features/simulation/logic/reactor_provider.dart';
import 'reactor_3d_view.dart';
import 'game_hud_widget.dart'; // 새로 만들 HUD
import 'control_panel_widget.dart'; // 새로 만들 하단 패널

class MainGameScreen extends StatelessWidget {
  const MainGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        children: [
          // 1. 배경: 인터랙티브 3D 원자로 (게임의 중심)
          // 화면 전체를 채우고, 핀치 줌/회전 가능하게 설정
          const Positioned.fill(child: Reactor3DView(isInteractive: true)),

          // 2. 상단: 자원 및 상태바 (Top HUD)
          const Positioned(top: 0, left: 0, right: 0, child: GameTopHud()),

          // 3. 우측: 실시간 그래프 및 경고 (접이식)
          const Positioned(top: 100, right: 10, child: SideMonitorWidget()),

          // 4. 하단: 조작 패널 (Control Deck)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ControlPanelWidget(),
          ),

          // 5. 이벤트 팝업 등은 Dialog로 처리
        ],
      ),
    );
  }
}
