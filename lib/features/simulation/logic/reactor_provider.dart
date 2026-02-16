import 'dart:math';
import 'package:flutter/material.dart';

// ReactorState: 방벽 내구도 데이터 추가
class ReactorState {
  final double temperature; // 노심 온도 (섭씨)
  final double pressure; // 압력 (MPa)
  final double controlRodLevel; // 제어봉 삽입률 (0.0 ~ 1.0)
  final double pumpSpeed; // 냉각재 펌프 속도 (0.0 ~ 1.0)
  final double electricalOutput; // 발전량 (MWe)
  final bool isScrammed; // 긴급 정지 여부
  final bool isMeltdown; // 멜트다운 여부

  // 🛡️ [NEW] 물리적 다중 방벽 내구도 (100.0 = 정상)
  final double fuelIntegrity; // 제1방벽: 연료 피복관
  final double vesselIntegrity; // 제2방벽: 원자로 용기
  final double containmentIntegrity; // 제3방벽: 격납 건물

  ReactorState({
    this.temperature = 295.0,
    this.pressure = 15.0,
    this.controlRodLevel = 1.0,
    this.pumpSpeed = 0.5,
    this.electricalOutput = 0.0,
    this.isScrammed = false,
    this.isMeltdown = false,
    this.fuelIntegrity = 100.0,
    this.vesselIntegrity = 100.0,
    this.containmentIntegrity = 100.0,
  });

  ReactorState copyWith({
    double? temperature,
    double? pressure,
    double? controlRodLevel,
    double? pumpSpeed,
    double? electricalOutput,
    bool? isScrammed,
    bool? isMeltdown,
    double? fuelIntegrity,
    double? vesselIntegrity,
    double? containmentIntegrity,
  }) {
    return ReactorState(
      temperature: temperature ?? this.temperature,
      pressure: pressure ?? this.pressure,
      controlRodLevel: controlRodLevel ?? this.controlRodLevel,
      pumpSpeed: pumpSpeed ?? this.pumpSpeed,
      electricalOutput: electricalOutput ?? this.electricalOutput,
      isScrammed: isScrammed ?? this.isScrammed,
      isMeltdown: isMeltdown ?? this.isMeltdown,
      fuelIntegrity: fuelIntegrity ?? this.fuelIntegrity,
      vesselIntegrity: vesselIntegrity ?? this.vesselIntegrity,
      containmentIntegrity: containmentIntegrity ?? this.containmentIntegrity,
    );
  }
}

class ReactorProvider extends ChangeNotifier {
  ReactorState _state = ReactorState();
  ReactorState get state => _state;

  // --- [사용자 조작] ---
  void setControlRod(double value) {
    if (_state.isScrammed) return; // 스크램 상태에선 조작 불가
    _state = _state.copyWith(controlRodLevel: value.clamp(0.0, 1.0));
    notifyListeners();
  }

  void setPumpSpeed(double value) {
    _state = _state.copyWith(pumpSpeed: value.clamp(0.0, 1.0));
    notifyListeners();
  }

  void scram() {
    _state = _state.copyWith(isScrammed: true, controlRodLevel: 1.0);
    notifyListeners();
  }

  // 🔧 [NEW] 유지보수 기능 (내구도 회복)
  void repairBarrier(String barrierType) {
    // 실제 게임에선 '예산'이나 '시간'을 소모해야 함
    switch (barrierType) {
      case 'fuel':
        _state = _state.copyWith(
          fuelIntegrity: min(100.0, _state.fuelIntegrity + 10),
        );
        break;
      case 'vessel':
        _state = _state.copyWith(
          vesselIntegrity: min(100.0, _state.vesselIntegrity + 10),
        );
        break;
      case 'containment':
        _state = _state.copyWith(
          containmentIntegrity: min(100.0, _state.containmentIntegrity + 10),
        );
        break;
    }
    notifyListeners();
  }

  void reset() {
    _state = ReactorState();
    notifyListeners();
  }

  // --- [물리 엔진 로직] ---
  void tick() {
    if (_state.isMeltdown) return;

    // 1. 열 발생
    double heatGen = 0.0;
    if (!_state.isScrammed) {
      heatGen = 12.0 * (1.0 - _state.controlRodLevel); // 출력 계수 상향 조정
    } else {
      heatGen = 0.5; // 잔열
    }

    // 2. 냉각
    double cooling =
        9.0 * _state.pumpSpeed * ((_state.temperature - 25.0) / 300.0);

    // 3. 온도 변화
    double nextTemp = _state.temperature + (heatGen - cooling) * 0.2;
    nextTemp -= 0.05; // 자연 냉각
    if (nextTemp < 25.0) nextTemp = 25.0;

    // 4. 압력 (이상 기체 법칙 단순화: PV=nRT -> P ~ T)
    double nextPressure = nextTemp * 0.05;

    // 5. 발전 효율
    double efficiency = max(0, 1.0 - (pow(nextTemp - 320, 2) / 2000));
    double output = _state.pumpSpeed * efficiency * 1200;

    // 🛡️ [NEW] 내구도 손상 로직 (스트레스 누적)
    double nextFuelHealth = _state.fuelIntegrity;
    double nextVesselHealth = _state.vesselIntegrity;
    double nextContainmentHealth = _state.containmentIntegrity;

    // A. 제1방벽 손상: 고온 지속 시
    if (nextTemp > 800) {
      nextFuelHealth -= 0.05; // 서서히 녹음
    }
    // B. 제2방벽 손상: 고압 지속 시 (20MPa 이상)
    if (nextPressure > 20.0) {
      nextVesselHealth -= 0.08; // 압력 용기 손상
    }
    // C. 제3방벽 손상: 멜트다운 발생 시 급격히 손상
    if (nextTemp > 1200) {
      nextContainmentHealth -= 0.5;
    }

    // 6. 멜트다운 및 게임오버 판정
    // 온도가 너무 높거나, 방벽 중 하나라도 깨지면 멜트다운
    bool meltdown =
        nextTemp > 1500.0 ||
        nextFuelHealth <= 0 ||
        nextVesselHealth <= 0 ||
        nextContainmentHealth <= 0;

    _state = _state.copyWith(
      temperature: nextTemp,
      pressure: nextPressure,
      electricalOutput: output,
      isMeltdown: meltdown,
      fuelIntegrity: max(0, nextFuelHealth),
      vesselIntegrity: max(0, nextVesselHealth),
      containmentIntegrity: max(0, nextContainmentHealth),
    );

    notifyListeners();
  }
}
