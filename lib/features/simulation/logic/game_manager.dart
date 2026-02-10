import 'dart:async';
import 'package:flutter/material.dart';
import 'reactor_provider.dart';

class GameManager extends ChangeNotifier {
  final ReactorProvider reactor;

  // ⏱️ 시간 설정: 1초(Real) = 10분(Game)
  // 14일 = 336시간 = 20,160분 = 실제 시간 2,016초 (약 33분)
  static const Duration tickDuration = Duration(seconds: 1);
  static const int minutesPerTick = 10;
  static const int maxDays = 14;

  int _day = 1;
  int _hour = 9; // 9시 시작
  int _minute = 0;
  bool _isPaused = true;
  bool _isGameOver = false;
  Timer? _timer;

  // 게임 로그 (UI 표시용)
  String _lastLog = "시스템 가동 준비 완료. 14일간 원자로를 사수하십시오.";

  GameManager({required this.reactor});

  // Getters
  int get day => _day;
  String get timeString =>
      "${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}";
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  String get lastLog => _lastLog;

  // ▶️ 게임 시작
  void startGame() {
    if (_isGameOver) return;

    if (_isPaused) {
      _isPaused = false;
      _timer = Timer.periodic(tickDuration, (timer) {
        _gameTick();
      });
      notifyListeners();
    }
  }

  // ⏸️ 일시 정지
  void pauseGame() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  // ⏩ [에러 해결] 시간 가속 (행동 수행 시 호출)
  // 예: 주민 설득(3시간) -> 3시간 동안 원자로 물리 연산 후 결과 반영
  void performAction(
    String actionName,
    int durationHours,
    VoidCallback onSuccess,
  ) {
    if (_isGameOver) return;

    // 3시간 = 180분. 1틱당 10분 = 18번 틱 수행
    int ticks = (durationHours * 60) ~/ minutesPerTick;

    _lastLog = "⏳ $actionName 진행 중... ($durationHours시간 소요)";
    notifyListeners();

    // 🚀 고속 시뮬레이션 (순식간에 n틱 돌림)
    for (int i = 0; i < ticks; i++) {
      if (_isGameOver) break; // 도중에 터지면 중단
      _gameTick();
    }

    if (!_isGameOver) {
      onSuccess();
      _lastLog = "✅ $actionName 완료. (현재 시간: $timeString)";
      notifyListeners();
    }
  }

  // 🔄 1틱마다 실행되는 로직
  void _gameTick() {
    // 1. 시간 흐름
    _minute += minutesPerTick;
    if (_minute >= 60) {
      _minute = 0;
      _hour++;
      if (_hour >= 24) {
        _hour = 0;
        _day++;
        _checkDayEvents(); // 날짜 변경 이벤트
      }
    }

    // 2. 원자로 물리 엔진 틱 업데이트 (실시간 반영)
    reactor.tick();

    // 3. 게임 오버 체크
    if (reactor.state.isMeltdown) {
      _finishGame("🚨 MELTDOWN: 과열로 인한 노심 용융! 미션 실패.");
    } else if (_day > maxDays) {
      _finishGame("🏆 MISSION COMPLETE: 14일간 무사고 운전 달성!");
    }

    notifyListeners();
  }

  // 📅 날짜별 시나리오 이벤트
  void _checkDayEvents() {
    if (_day == 3) {
      _lastLog = "⚠️ 폭염 주의보: 냉각수 온도가 상승합니다.";
    } else if (_day == 7) {
      _lastLog = "⚠️ 지진 감지: 설비 내구도를 확인하세요.";
    } else if (_day == 10) {
      _lastLog = "📢 정보: 발전소 앞 대규모 시위 발생. 주민 설득이 필요합니다.";
    } else {
      _lastLog = "📅 Day $_day 시작. 특이사항 없음.";
    }
  }

  void _finishGame(String resultMsg) {
    _isGameOver = true;
    _isPaused = true;
    _timer?.cancel();
    _lastLog = resultMsg;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
