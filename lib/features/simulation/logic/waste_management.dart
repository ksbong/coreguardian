// lib/features/simulation/logic/waste_management.dart

enum WasteType { highLevel, intermediateLevel, lowLevel, veryLowLevel, exempt }

class RadioactiveWaste {
  final String name;
  final double radioactivityLevel; // Bq/g (방사능 농도)
  final bool generatesHeat; // 열 발생 여부 (고준위 판별 핵심)
  final WasteType correctClassification;

  RadioactiveWaste(
    this.name,
    this.radioactivityLevel,
    this.generatesHeat,
    this.correctClassification,
  );
}

class WasteMinigameLogic {
  List<RadioactiveWaste> pendingWaste = [
    RadioactiveWaste(
      '사용후핵연료',
      1000000.0,
      true,
      WasteType.highLevel,
    ), // 열 발생, 고농도
    RadioactiveWaste('오염된 펌프 부품', 500.0, false, WasteType.intermediateLevel),
    RadioactiveWaste('사용한 작업복/장갑', 50.0, false, WasteType.lowLevel),
    RadioactiveWaste(
      '일반 구역 청소 도구',
      0.1,
      false,
      WasteType.exempt,
    ), // 자체처분 (면제 수준)
  ];

  int score = 0;
  int strikes = 0; // 오분류 시 페널티 스택

  void classifyWaste(RadioactiveWaste waste, WasteType playerChoice) {
    if (waste.correctClassification == playerChoice) {
      score += 15;
      // 대중의 신뢰도(Persuasion) 및 안전 점수 상승 로직 연동
    } else {
      strikes++;
      // 안전도 대폭 하락, 예산 차감(벌금)
      // "원안위 고시에 따르면 해당 폐기물은 [정답]로 분류되어야 합니다." 형태의 피드백 모달 노출
    }
    pendingWaste.remove(waste);
  }
}
