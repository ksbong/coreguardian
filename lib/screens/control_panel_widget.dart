import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../features/simulation/logic/reactor_provider.dart';
import '../features/simulation/logic/game_manager.dart';
import 'safety_maintenance_screen.dart';

class ControlPanelWidget extends StatefulWidget {
  const ControlPanelWidget({super.key});

  @override
  State<ControlPanelWidget> createState() => _ControlPanelWidgetState();
}

class _ControlPanelWidgetState extends State<ControlPanelWidget> {
  bool _isExpanded = true; // 기본적으로 펼쳐둠

  @override
  Widget build(BuildContext context) {
    final reactor = context.watch<ReactorProvider>();
    final state = reactor.state;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
      children: [
        // 1. 메인 패널 (애니메이션 컨테이너)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isExpanded ? 260 : 0, // 너비 조절 (접으면 0)
          height: 550, // 세로로 길게 (화면 높이에 맞게 조정 가능)
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2228).withValues(alpha: 0.9),
                  border: const Border(
                    right: BorderSide(
                      color: Colors.cyanAccent,
                      width: 1,
                    ), // 오른쪽 테두리
                  ),
                ),
                child: Column(
                  children: [
                    // 타이틀
                    Text(
                      "CONTROL DECK",
                      style: GoogleFonts.oswald(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // A. 디지털 계기판 (상단 배치)
                    _buildDigitalDisplay(
                      "CORE TEMP",
                      "${state.temperature.toStringAsFixed(0)}°C",
                      state.temperature > 800 ? Colors.red : Colors.greenAccent,
                    ),
                    const SizedBox(height: 8),
                    _buildDigitalDisplay(
                      "ELEC. OUTPUT",
                      "${state.electricalOutput.toStringAsFixed(0)} MW",
                      Colors.yellowAccent,
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),

                    // B. 슬라이더 (세로로 배치)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 제어봉 슬라이더
                          _buildVerticalSlider(
                            "RODS",
                            state.controlRodLevel,
                            (v) => reactor.setControlRod(v),
                            Colors.orangeAccent,
                          ),
                          // 펌프 슬라이더
                          _buildVerticalSlider(
                            "PUMPS",
                            state.pumpSpeed,
                            (v) => reactor.setPumpSpeed(v),
                            Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // C. 하단 버튼 그룹 (SCRAM 포함)
                    Column(
                      children: [
                        _buildMenuButton(
                          icon: Icons.security,
                          label: "SAFETY CHK",
                          color: Colors.cyanAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SafetyMaintenanceScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildMenuButton(
                          icon: Icons.people,
                          label: "RESIDENTS",
                          color: Colors.white70,
                          onTap: () => context
                              .read<GameManager>()
                              .performAction("주민 여론 조사", 1, () {}),
                        ),
                        const SizedBox(height: 15),

                        // SCRAM 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                            ),
                            onPressed: () => reactor.scram(),
                            child: const Text(
                              "EMERGENCY SCRAM",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. 접기/펼치기 핸들 (패널 오른쪽에 붙음)
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            margin: const EdgeInsets.only(top: 20), // 위에서 조금 띄움
            width: 24,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
              border: Border(
                right: BorderSide(color: Colors.cyanAccent, width: 1),
                top: BorderSide(color: Colors.cyanAccent, width: 1),
                bottom: BorderSide(color: Colors.cyanAccent, width: 1),
              ),
            ),
            child: Center(
              child: Icon(
                _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.cyanAccent,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🎚️ 세로 슬라이더 빌더 (기존과 동일하지만 높이 최적화)
  Widget _buildVerticalSlider(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 12, // 트랙을 좀 더 두껍게
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                activeTrackColor: color,
                inactiveTrackColor: Colors.black45,
                thumbColor: Colors.white,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "${(value * 100).toInt()}%",
          style: GoogleFonts.shareTechMono(color: color, fontSize: 14),
        ),
      ],
    );
  }

  // 📟 디지털 디스플레이
  Widget _buildDigitalDisplay(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 버튼
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.oswald(color: color)),
          ],
        ),
      ),
    );
  }
}
