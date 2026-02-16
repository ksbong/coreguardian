// lib/features/simulation/logic/daily_stats.dart

class DailyStats {
  final int day;
  double totalEnergyGenerated; // 총 발전량 (MWh)
  int safetyViolations; // 안전 규정 위반 횟수 (온도/압력 경고)
  double maxTemperatureReached; // 최고 도달 온도
  double publicTrustChange; // 여론 변화량

  DailyStats({
    required this.day,
    this.totalEnergyGenerated = 0.0,
    this.safetyViolations = 0,
    this.maxTemperatureReached = 0.0,
    this.publicTrustChange = 0.0,
  });

  // 등급 계산 (S~F)
  String get grade {
    if (safetyViolations == 0 && totalEnergyGenerated > 5000) return "S";
    if (safetyViolations < 5) return "A";
    if (safetyViolations < 10) return "B";
    if (safetyViolations < 20) return "C";
    return "F"; // 규정 위반 과다
  }
}
