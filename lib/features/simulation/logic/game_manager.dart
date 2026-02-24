import 'dart:async';
import 'package:flutter/material.dart';
import 'reactor_provider.dart';
import 'daily_stats.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // 패키지 설치 후 주석 해제

class GameManager extends ChangeNotifier {
  final ReactorProvider reactor;

  static const Duration tickDuration = Duration(seconds: 1);
  static const int minutesPerTick = 10;
  static const int maxDays = 14;

  int _day = 1;
  int _hour = 9; // 9시 시작
  int _minute = 0;
  bool _isPaused = true;
  bool _isGameOver = false;
  Timer? _timer;

  // 📊 DailyStats 누적용 변수들
  double _dailyEnergyAccumulated = 0.0;
  double _dailyMaxTemp = 0.0;
  int _dailyViolations = 0;
  double _dailyTrustChange = 0.0;

  // 🎬 UI 전환 콜백 (main_game_screen.dart에서 연결)
  Function(DailyStats)? onDayEnded;
  VoidCallback? onMinigameTriggered;

  String _lastLog = "시스템 가동 준비 완료. 14일간 원자로를 사수하십시오.";

  GameManager({required this.reactor});

  // Getters
  int get day => _day;
  String get timeString =>
      "${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}";
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  String get lastLog => _lastLog;

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

  void pauseGame() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void performAction(
    String actionName,
    int durationHours,
    VoidCallback onSuccess,
  ) {
    if (_isGameOver) return;

    int ticks = (durationHours * 60) ~/ minutesPerTick;
    _lastLog = "⏳ $actionName 진행 중... ($durationHours시간 소요)";
    notifyListeners();

    for (int i = 0; i < ticks; i++) {
      if (_isGameOver) break;
      _gameTick();
    }

    if (!_isGameOver) {
      onSuccess();
      _lastLog = "✅ $actionName 완료. (현재 시간: $timeString)";
      notifyListeners();
    }
  }

  void _gameTick() {
    _minute += minutesPerTick;

    // 1. 물리 엔진 업데이트
    reactor.tick();

    // 2. 일일 통계 누적
    // 발전량 (MW -> 10분 단위 누적이므로 MWh로 환산하기 위해 / 6)
    _dailyEnergyAccumulated += (reactor.state.electricalOutput / 6);

    if (reactor.state.temperature > _dailyMaxTemp) {
      _dailyMaxTemp = reactor.state.temperature;
    }

    // 온도 800도 초과 시 안전 위반 카운트 증가
    if (reactor.state.temperature > 800.0) {
      _dailyViolations++;
      _dailyTrustChange -= 1.0; // 위반 시 여론 악화
    }

    // 3. 시간 및 날짜 변경 처리
    if (_minute >= 60) {
      _minute = 0;
      _hour++;

      // ⚠️ 오후 2시 (14시) 폐기물 미니게임 트리거 (예: 3일마다 발생)
      if (_hour == 14 && _day % 3 == 0) {
        pauseGame();
        _lastLog = "⚠️ 경고: 방사성 폐기물 반입. 즉시 분류 작업을 시작하십시오.";
        onMinigameTriggered?.call();
      }

      // 🌙 자정 (24시) 일과 종료
      if (_hour >= 24) {
        _hour = 0;
        _endDay();
      }
    }

    // 4. 게임 오버 체크
    if (reactor.state.isMeltdown) {
      _finishGame("🚨 MELTDOWN: 과열로 인한 노심 용융! 미션 실패.");
    } else if (_day > maxDays) {
      _finishGame("🏆 MISSION COMPLETE: 14일간 무사고 운전 달성!");
    }

    notifyListeners();
  }

  void _endDay() {
    pauseGame(); // 정산창이 떠 있는 동안 시간 멈춤

    // 네가 작성한 DailyStats 객체 생성
    DailyStats todayStats = DailyStats(
      day: _day,
      totalEnergyGenerated: _dailyEnergyAccumulated,
      safetyViolations: _dailyViolations,
      maxTemperatureReached: _dailyMaxTemp,
      publicTrustChange: _dailyTrustChange,
    );

    // DB에 데이터 쏘기
    _saveToSupabase(todayStats);

    // UI에 정산 화면 띄우라고 신호 전달
    if (onDayEnded != null) {
      onDayEnded!(todayStats);
    }
  }

  void startNextDay() {
    _day++;
    _hour = 9; // 다음 날 9시 재시작
    _minute = 0;

    // 누적 데이터 초기화
    _dailyEnergyAccumulated = 0.0;
    _dailyMaxTemp = 0.0;
    _dailyViolations = 0;
    _dailyTrustChange = 0.0;

    _checkDayEvents();
    startGame();
  }

  void _checkDayEvents() {
    if (_day == 3) {
      _lastLog = "⚠️ 폭염 주의보: 냉각수 온도가 상승합니다.";
    } else if (_day == 7) {
      _lastLog = "⚠️ 지진 감지: 설비 내구도를 확인하세요.";
    } else if (_day == 10) {
      _lastLog = "📢 정보: 발전소 앞 대규모 시위 발생. 주민 설득이 필요합니다.";
    } else {
      _lastLog = "📅 Day $_day 일과 시작. 특이사항 없음.";
    }
  }

  void _finishGame(String resultMsg) {
    _isGameOver = true;
    _isPaused = true;
    _timer?.cancel();
    _lastLog = resultMsg;
    notifyListeners();
  }

  // 💾 Supabase 저장 로직 (첨부한 스키마 기반 upsert)
  Future<void> _saveToSupabase(DailyStats stats) async {
    try {
      /*
      // 실제 연결 시 사용할 코드
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('daily_stats').upsert({
        'user_id': userId,
        'day': stats.day,
        'total_energy': stats.totalEnergyGenerated,
        'violations': stats.safetyViolations,
        'max_temp': stats.maxTemperatureReached,
        'trust_change': stats.publicTrustChange,
        'grade': stats.grade, // 네가 만든 getter 호출
        'updated_at': DateTime.now().toIso8601String(),
      });
      */
      debugPrint("Day ${stats.day} Supabase 저장 완료 (Grade: ${stats.grade})");
    } catch (e) {
      debugPrint("DB 저장 실패: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
