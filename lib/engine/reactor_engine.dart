import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class ReactorEngine {
  // --- [싱글톤 설정] ---
  static final ReactorEngine _instance = ReactorEngine._internal();
  factory ReactorEngine() => _instance;
  ReactorEngine._internal();

  // --- [3C: 원자력 안전 핵심 변수] ---
  double power = 100.0; // Control: 현재 출력 (%) [cite: 210]
  double temperature = 280.0; // Cooling: 냉각수 온도 (°C) [cite: 211]
  double integrity = 100.0; // Containment: 방벽 내구도 (%)

  // --- [핵심 물리 개념] ---
  double decayHeat = 0.0; // 붕괴열: 정지 후에도 발생하는 잔열 [cite: 196-198]
  bool isScrammed = false; // 긴급 정지 여부 (SCRAM)

  Timer? _timer;

  // 엔진 시작
  void start() {
    debugPrint("🏗️ 원자로 엔진 시동 중...");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updatePhysics();
    });
  }

  void _updatePhysics() {
    const double ambientTemp = 25.0;

    // 1. 제어(Control): SCRAM 시 출력은 0이 되지만 붕괴열이 발생함
    if (isScrammed) {
      power = 0.0;
      decayHeat *= 0.95; // 붕괴열이 시간에 따라 서서히 감소 [cite: 200]
    }

    // 2. 냉각(Cooling): 발생 열(출력+붕괴열)과 냉각 성능의 평형 계산
    double heatInput = power + decayHeat;

    // 냉각 로직 수정: 현재 온도와 상온의 차이가 클수록 냉각이 잘 됨 (현실적 로직)
    // 온도가 상온에 가까워지면 냉각 효율이 0에 수렴함
    double coolingEffect = (temperature - ambientTemp) * 0.1;

    // 펌프가 가동 중일 때 기본 냉각 성능 추가 (플레이어 조작 요소)
    double activeCooling = 5.0;

    // 온도 변화 계산
    double deltaTemp = (heatInput - activeCooling - coolingEffect) * 0.1;
    temperature += deltaTemp;

    // 하한선 강제 고정: 상온 이하로 떨어지지 않음
    temperature = max(ambientTemp, temperature);

    debugPrint(
      "🌡️ 온도: ${temperature.toStringAsFixed(1)}°C | 출력: $power% | 붕괴열: ${decayHeat.toStringAsFixed(1)}%",
    );

    if (temperature > 350.0 && !isScrammed) {
      scram();
    }
  }

  // 긴급 정지 (SCRAM): 제어봉을 즉시 삽입 [cite: 228, 251]
  void scram() {
    if (isScrammed) return;
    isScrammed = true;
    decayHeat = 7.0; // 정지 직후 약 7%의 붕괴열 발생
    debugPrint("🚨 [SAFETY SYSTEM] 자동 보호 시스템 작동: 원자로 정지");
  }

  // 5중 물리적 방벽 데이터 [cite: 294]
  List<Map<String, dynamic>> barriers = [
    {"name": "제1방호벽: 핵연료 펠렛", "desc": "방사성 물질 1차 밀폐", "health": 100.0},
    {"name": "제2방호벽: 연료 피복관", "desc": "지르코늄 합금으로 기체까지 밀폐", "health": 100.0},
    {"name": "제3방호벽: 원자로 압력용기", "desc": "23cm 두께 강철 용기", "health": 100.0},
    {"name": "제4방호벽: 격납용기", "desc": "6~7mm 두께 내벽 강철판", "health": 100.0},
    {"name": "제5방호벽: 원자로 건물", "desc": "120cm 두께 철근 콘크리트 외벽", "health": 100.0},
  ];

  // 온도가 너무 높을 때 방벽 내구도를 깎는 로직 (내일 UI 연결용)
  void _checkBarrierIntegrity() {
    // 예: 온도가 1000도를 넘으면 1단계부터 서서히 손상
    if (temperature > 1000.0) {
      for (var barrier in barriers) {
        if (barrier['health'] > 0) {
          barrier['health'] -= 1.0; // 온도가 높을수록 벽이 녹음 (Meltdown 과정)
          break; // 1단계가 다 깨져야 2단계가 깨짐 (심층방어 전략) [cite: 215]
        }
      }
    }
  }
}
