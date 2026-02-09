import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../features/simulation/logic/reactor_provider.dart';
import '../features/simulation/logic/game_manager.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reactor = context.watch<ReactorProvider>();
    final reactorCtrl = context.read<ReactorProvider>();
    final game = context.watch<GameManager>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // [상단] 시스템 로그 & 경고창
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // 1. 실시간 그래프 (온도 변화 추이) - 있어빌리티의 핵심
                Expanded(
                  flex: 2,
                  child: _buildPanel(
                    title: "REAL-TIME CORE TEMP",
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white12),
                        ),
                        minY: 0,
                        maxY: 1200,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              // 더미 데이터: 실제론 reactor.history 같은 걸 만들어서 연결해야 함
                              const FlSpot(0, 300),
                              const FlSpot(1, 310),
                              const FlSpot(2, 290),
                              const FlSpot(3, 350),
                              FlSpot(4, reactor.state.temperature),
                            ],
                            isCurved: true,
                            color: Colors.redAccent,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.redAccent.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 2. 시스템 로그
                Expanded(
                  flex: 1,
                  child: _buildPanel(
                    title: "SYSTEM LOGS",
                    child: ListView(
                      children: [
                        Text(
                          "> System Initialized...",
                          style: GoogleFonts.firaCode(
                            color: Colors.green,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          "> Check pump status: OK",
                          style: GoogleFonts.firaCode(
                            color: Colors.green,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "> ${game.log}",
                          style: GoogleFonts.firaCode(
                            color: Colors.yellowAccent,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // [중단] 핵심 계기판 (온도, 압력, 출력)
          Expanded(
            flex: 1,
            child: Row(
              children: [
                _buildDigitalGauge(
                  "TEMP",
                  "${reactor.state.temperature.toStringAsFixed(1)} °C",
                  reactor.state.temperature > 800 ? Colors.red : Colors.green,
                ),
                _buildDigitalGauge(
                  "PRESSURE",
                  "${reactor.state.pressure.toStringAsFixed(1)} MPa",
                  Colors.amber,
                ),
                _buildDigitalGauge("OUTPUT", "850 MW", Colors.cyan),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // [하단] 컨트롤 패널 (스위치 & 슬라이더)
          Expanded(
            flex: 2,
            child: _buildPanel(
              title: "MANUAL OVERRIDE CONTROL",
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlRow(
                    "CONTROL RODS",
                    reactor.state.controlRodLevel,
                    Colors.orange,
                    (v) => reactorCtrl.setControlRod(v),
                  ),
                  const SizedBox(height: 15),
                  _buildControlRow(
                    "COOLANT PUMP",
                    reactor.state.pumpSpeed,
                    Colors.blueAccent,
                    (v) => reactorCtrl.setPumpSpeed(v),
                  ),
                  const SizedBox(height: 15),
                  // 긴급 정지 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () => reactorCtrl.scram(),
                      icon: const Icon(Icons.warning, color: Colors.red),
                      label: Text(
                        "EMERGENCY SCRAM",
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI 컴포넌트들
  Widget _buildPanel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2126),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.shareTechMono(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          const Divider(color: Colors.white12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDigitalGauge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRow(
    String label,
    double val,
    Color color,
    Function(double) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: color,
            ),
            child: Slider(value: val, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            "${(val * 100).toInt()}%",
            style: GoogleFonts.firaCode(color: color),
          ),
        ),
      ],
    );
  }
}
