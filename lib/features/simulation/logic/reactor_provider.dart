import 'dart:math';
import 'package:flutter/material.dart';

// ReactorState는 기존 그대로 유지 (데이터 클래스)
class ReactorState {
  final double temperature; // 노심 온도 (섭씨)
  final double pressure; // 압력 (MPa)
  final double controlRodLevel; // 제어봉 삽입률 (0.0 ~ 1.0)
  final double pumpSpeed; // 냉각재 펌프 속도 (0.0 ~ 1.0)
  final double electricalOutput; // 발전량 (MWe)
  final bool isScrammed; // 긴급 정지 여부
  final bool isMeltdown; // 멜트다운 여부

  ReactorState({
    this.temperature = 295.0,
    this.pressure = 15.0,
    this.controlRodLevel = 1.0,
    this.pumpSpeed = 0.5,
    this.electricalOutput = 0.0,
    this.isScrammed = false,
    this.isMeltdown = false,
  });

  ReactorState copyWith({
    double? temperature,
    double? pressure,
    double? controlRodLevel,
    double? pumpSpeed,
    double? electricalOutput,
    bool? isScrammed,
    bool? isMeltdown,
  }) {
    return ReactorState(
      temperature: temperature ?? this.temperature,
      pressure: pressure ?? this.pressure,
      controlRodLevel: controlRodLevel ?? this.controlRodLevel,
      pumpSpeed: pumpSpeed ?? this.pumpSpeed,
      electricalOutput: electricalOutput ?? this.electricalOutput,
      isScrammed: isScrammed ?? this.isScrammed,
      isMeltdown: isMeltdown ?? this.isMeltdown,
    );
  }
}

class ReactorProvider extends ChangeNotifier {
  ReactorState _state = ReactorState();
  ReactorState get state => _state;

  // ⚠️ 중요: 내부 Timer(_gameLoop)는 제거함.
  // 이유는 이제 GameManager가 시간을 관리하면서 tick()을 호출해주기 때문임.

  // --- [사용자 조작] ---
  void setControlRod(double value) {
    if (_state.isScrammed) return;
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

  void reset() {
    _state = ReactorState();
    notifyListeners();
  }

  // --- [물리 엔진 로직] ---
  // GameManager에서 1초마다(혹은 가속 시 빠르게) 이 함수를 부름
  void tick() {
    if (_state.isMeltdown) return;

    // 🔥 [복구 완료] 네가 작성했던 디테일한 물리 공식 적용

    // 1. 열 발생 (제어봉에 반비례)
    double heatGen = 0.0;
    if (!_state.isScrammed) {
      heatGen = 10.0 * (1.0 - _state.controlRodLevel);
    } else {
      heatGen = 0.5; // 잔열 (SCRAM 상태에서도 열이 조금 발생)
    }

    // 2. 냉각 (펌프 속도와 온도 차이에 비례)
    // 공식: 8.0 * 펌프속도 * ((현재온도 - 25도) / 300)
    double cooling =
        8.0 * _state.pumpSpeed * ((_state.temperature - 25.0) / 300.0);

    // 3. 온도 변화 계산
    double nextTemp = _state.temperature + (heatGen - cooling) * 0.1;
    nextTemp -= 0.05; // 자연 냉각 상수
    if (nextTemp < 25.0) nextTemp = 25.0; // 실온 밑으로 안 떨어짐

    // 4. 압력 계산 (온도에 비례)
    double nextPressure = nextTemp * 0.048;

    // 5. 발전 효율 계산 (315도에서 최대 효율이 나오는 2차 함수 그래프)
    // 이 로직이 있어야 게임이 재밌음 (무조건 뜨겁다고 좋은 게 아님)
    double efficiency = max(0, 1.0 - (pow(nextTemp - 315, 2) / 1000));

    // 6. 최종 발전량 (MWe)
    double output = _state.pumpSpeed * efficiency * 1000;

    // 7. 멜트다운 판정 (1200도 초과)
    bool meltdown = nextTemp > 1200.0;

    // 상태 업데이트
    _state = _state.copyWith(
      temperature: nextTemp,
      pressure: nextPressure,
      electricalOutput: output,
      isMeltdown: meltdown,
    );

    notifyListeners();
  }
}
