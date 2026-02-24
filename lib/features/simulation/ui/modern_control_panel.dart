import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernControlPanel extends StatelessWidget {
  final double controlRodPosition;
  final Function(double) onControlRodChanged;
  final double coolantFlow;
  final Function(double) onCoolantFlowChanged;

  const ModernControlPanel({
    super.key,
    required this.controlRodPosition,
    required this.onControlRodChanged,
    required this.coolantFlow,
    required this.onCoolantFlowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 2),
        boxShadow: [
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlKnob(
            "제어봉 삽입률",
            controlRodPosition,
            onControlRodChanged,
            Colors.orangeAccent,
          ),
          _buildControlKnob(
            "냉각수 유량",
            coolantFlow,
            onCoolantFlowChanged,
            Colors.blueAccent,
          ),
          // 긴급 정지 버튼 (SCRAM)
          Column(
            children: [
              Text(
                "SCRAM",
                style: GoogleFonts.orbitron(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  onControlRodChanged(100.0); // 즉시 100% 삽입
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  backgroundColor: Colors.red,
                  elevation: 10,
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlKnob(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 10),
        SleekCircularSlider(
          initialValue: value,
          max: 100,
          appearance: CircularSliderAppearance(
            size: 120,
            customColors: CustomSliderColors(
              progressBarColor: color,
              trackColor: Colors.grey[800],
              shadowColor: color.withOpacity(0.5),
            ),
            infoProperties: InfoProperties(
              mainLabelStyle: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 24,
              ),
              modifier: (double value) => '${value.toStringAsFixed(0)}%',
            ),
          ),
          onChange: onChanged,
        ),
      ],
    );
  }
}
