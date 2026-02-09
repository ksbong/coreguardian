import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../features/simulation/logic/game_manager.dart';
import 'dashboard_screen.dart'; // [1] 중앙 제어실
import 'reactor_3d_view.dart'; // [2] 3D 현장 모니터
import 'office_screen.dart'; // [3] 행정실 (NPC)
// import 'waste_screen.dart';    // [4] 폐기물 (추후 구현)

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  int _selectedIndex = 0; // 현재 선택된 메뉴

  // 화면 리스트 (인덱스 순서대로)
  final List<Widget> _screens = [
    const DashboardScreen(), // 0: MCR
    const Reactor3DView(), // 1: 3D View
    const OfficeScreen(), // 2: Office
    const Center(
      child: Text("폐기물 처리장 (준비중)", style: TextStyle(color: Colors.white)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameManager>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // Deep Dark Background
      // 상단 상태바 (항상 떠있는 정보)
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B21),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.hub, color: Colors.cyanAccent, size: 20),
            const SizedBox(width: 10),
            Text(
              "STATERA OS v1.0",
              style: GoogleFonts.shareTechMono(
                color: Colors.cyanAccent,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            // 날짜 및 시간 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "DAY ${game.day} | ${game.hour.toString().padLeft(2, '0')}:00",
                style: GoogleFonts.shareTechMono(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      // 메인 콘텐츠 영역 (IndexedStack으로 상태 유지하며 화면 전환)
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // 하단 내비게이션 (전문가용 메뉴판 느낌)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12)),
          color: Color(0xFF121418),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.speed, "MCR", "중앙제어"),
            _buildNavItem(1, Icons.view_in_ar, "VIEW", "현장확인"),
            _buildNavItem(2, Icons.people_alt, "OFFICE", "대외업무"),
            _buildNavItem(3, Icons.warning_amber, "WASTE", "폐기물"),
          ],
        ),
      ),
    );
  }

  // 커스텀 내비게이션 버튼
  Widget _buildNavItem(int index, IconData icon, String label, String sub) {
    bool isSelected = _selectedIndex == index;
    Color color = isSelected ? Colors.cyanAccent : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.oswald(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              sub,
              style: TextStyle(color: color.withOpacity(0.5), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
