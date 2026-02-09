import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
  Timer? _gameLoop;

  ReactorProvider() {
    _startSimulation();
  }

  void _startSimulation() {
    // 0.1초마다 1틱(약 게임시간 1분) 진행
    _gameLoop = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _tick();
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

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

  // --- [에러 해결: 빠진 함수들 추가] ---

  // 1. 시간 가속 (GameManager가 호출함)
  bool simulateTimePass(int hours) {
    int totalTicks = hours * 60; // 1시간 = 60틱(분)으로 가정하고 빠르게 돌림

    for (int i = 0; i < totalTicks; i++) {
      _tick(); // 물리 연산 수행
      if (_state.isMeltdown) {
        // 돌리는 도중 터지면 중단
        notifyListeners();
        return false;
      }
    }
    notifyListeners();
    return true; // 무사함
  }

  // 2. 초기화 (재시작 시 호출됨)
  void reset() {
    _state = ReactorState(); // 초기 상태로 리셋
    notifyListeners();
  }

  // --- [물리 엔진 로직] ---
  void _tick() {
    if (_state.isMeltdown) {
      // 멜트다운 시 타이머는 돌지만 연산은 멈춤 (또는 타이머 취소)
      _gameLoop?.cancel();
      return;
    }

    // 열 발생
    double heatGen = 0.0;
    if (!_state.isScrammed) {
      heatGen = 10.0 * (1.0 - _state.controlRodLevel);
    } else {
      heatGen = 0.5; // 잔열
    }

    // 냉각
    double cooling =
        8.0 * _state.pumpSpeed * ((_state.temperature - 25.0) / 300.0);

    // 온도 변화
    double nextTemp = _state.temperature + (heatGen - cooling) * 0.1;
    nextTemp -= 0.05; // 자연 냉각
    if (nextTemp < 25.0) nextTemp = 25.0;

    // 압력
    double nextPressure = nextTemp * 0.048;

    // 발전량
    double efficiency = max(0, 1.0 - (pow(nextTemp - 315, 2) / 1000));
    double output = _state.pumpSpeed * efficiency * 1000;

    // 멜트다운 체크
    bool meltdown = nextTemp > 1200.0;

    _state = _state.copyWith(
      temperature: nextTemp,
      pressure: nextPressure,
      electricalOutput: output,
      isMeltdown: meltdown,
    );

    notifyListeners();
  }
}
