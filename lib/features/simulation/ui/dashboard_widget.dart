import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/reactor_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚡ ReactorProvider의 상태만 구독 (UI 갱신 최적화)
    final reactor = context.watch<ReactorProvider>();
    final state = reactor.state;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MAIN CONTROL ROOM",
            style: GoogleFonts.oswald(color: Colors.cyanAccent, fontSize: 24),
          ),
          const SizedBox(height: 20),

          // 1. 핵심 계기판 (온도, 압력 등)
          Row(
            children: [
              _buildGauge(
                "CORE TEMP",
                "${state.temperature.toStringAsFixed(1)} °C",
                state.temperature > 800 ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 15),
              _buildGauge(
                "PRESSURE",
                "${state.pressure.toStringAsFixed(1)} MPa",
                state.pressure > 16 ? Colors.orange : Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 2. 조작 패널 (슬라이더)
          Text(
            "SYSTEM CONTROLS",
            style: GoogleFonts.oswald(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 10),

          _buildControlSlider(
            "CONTROL ROD (제어봉)",
            state.controlRodLevel,
            (val) => reactor.setControlRod(val),
            Colors.orangeAccent,
          ),

          _buildControlSlider(
            "COOLANT PUMP (냉각 펌프)",
            state.pumpSpeed,
            (val) => reactor.setPumpSpeed(val),
            Colors.blueAccent,
          ),

          const Spacer(),

          // 3. SCRAM 버튼 (긴급 정지)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: .8),
              ),
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              label: const Text(
                "MANUAL SCRAM (긴급 정지)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => reactor.scram(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black45,
          border: Border.all(color: color.withValues(alpha: .5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.shareTechMono(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSlider(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          inactiveColor: Colors.white10,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
