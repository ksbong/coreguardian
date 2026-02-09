import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  final double temperature;
  final double pressure;
  final double output;

  const DashboardWidget({
    super.key,
    required this.temperature,
    required this.pressure,
    required this.output,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222), // 짙은 회색 패널
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "REACTOR STATUS MONITOR",
            style: TextStyle(
              color: Colors.white54,
              letterSpacing: 1.5,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 온도 게이지
              _buildDigitalGauge(
                "CORE TEMP",
                temperature,
                "°C",
                290,
                330,
                1200,
              ),
              // 압력 게이지
              _buildDigitalGauge("PRESSURE", pressure, "MPa", 14.0, 16.0, 20.0),
              // 발전량 게이지
              _buildDigitalGauge("OUTPUT", output, "MWe", 800, 1000, 1200),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalGauge(
    String label,
    double value,
    String unit,
    double minSafe,
    double maxSafe,
    double danger,
  ) {
    // 상태에 따른 색상 결정 (안전: 초록, 주의: 주황, 위험: 빨강)
    Color statusColor = Colors.greenAccent;
    if (value > maxSafe || value < minSafe) statusColor = Colors.orangeAccent;
    if (value > danger) statusColor = Colors.redAccent;

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 3),
            color: Colors.black,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 18,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // 상태 표시 LED
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: statusColor, blurRadius: 5)],
          ),
        ),
      ],
    );
  }
}
