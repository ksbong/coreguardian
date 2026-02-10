import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // ImageFilter 사용 위함
import '../features/simulation/logic/reactor_provider.dart';

class ControlPanelWidget extends StatefulWidget {
  const ControlPanelWidget({super.key});

  @override
  State<ControlPanelWidget> createState() => _ControlPanelWidgetState();
}

class _ControlPanelWidgetState extends State<ControlPanelWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final reactor = context.watch<ReactorProvider>();
    final state = reactor.state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 패널 접기/펼치기 핸들
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            width: 60,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Icon(
              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.cyanAccent,
              size: 16,
            ),
          ),
        ),

        // 메인 컨트롤 패널
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? 180 : 0, // 높이 조절
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2228).withValues(alpha: .85),
                  border: const Border(
                    top: BorderSide(color: Colors.cyanAccent, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // 왼쪽: 제어봉 (Control Rods)
                    Expanded(
                      child: _buildVerticalSlider(
                        "CONTROL RODS",
                        state.controlRodLevel,
                        (v) => reactor.setControlRod(v),
                        Colors.orangeAccent,
                      ),
                    ),

                    const SizedBox(width: 20),

                    // 중앙: 핵심 수치 (게이지)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDigitalDisplay(
                          "TEMP",
                          "${state.temperature.toStringAsFixed(0)}°C",
                          state.temperature > 800
                              ? Colors.red
                              : Colors.greenAccent,
                        ),
                        const SizedBox(height: 10),
                        _buildDigitalDisplay(
                          "POWER",
                          "${state.electricalOutput.toStringAsFixed(0)} MW",
                          Colors.yellowAccent,
                        ),
                        const SizedBox(height: 10),
                        // 긴급 정지 버튼 (작게 배치)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: .7),
                          ),
                          onPressed: () => reactor.scram(),
                          child: const Text(
                            "SCRAM",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    // 오른쪽: 펌프 (Pumps)
                    Expanded(
                      child: _buildVerticalSlider(
                        "COOLANT PUMP",
                        state.pumpSpeed,
                        (v) => reactor.setPumpSpeed(v),
                        Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        Expanded(
          child: RotatedBox(
            quarterTurns: 3, // 세로 슬라이더로 변환
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 10,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: color,
                inactiveTrackColor: Colors.black45,
                thumbColor: Colors.white,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ),
        Text(
          "${(value * 100).toInt()}%",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDigitalDisplay(String label, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8)),
          Text(
            value,
            style: GoogleFonts.shareTechMono(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
