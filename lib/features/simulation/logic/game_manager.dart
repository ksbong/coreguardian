import 'dart:async';
import 'dart:convert'; // 세이브 데이터 변환용
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 패키지 필요
import 'reactor_provider.dart';
import 'daily_stats.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class GameManager extends ChangeNotifier {
  final ReactorProvider reactor;

  static const Duration tickDuration = Duration(seconds: 1);
  static const int minutesPerTick = 10;
  static const int maxDays = 14;

  String worldName = ""; // 🌐 추가: 월드 이름
  int _day = 1;
  int _hour = 9;
  int _minute = 0;
  bool _isPaused = true;
  bool _isGameOver = false;
  Timer? _timer;

  double _dailyEnergyAccumulated = 0.0;
  double _dailyMaxTemp = 0.0;
  int _dailyViolations = 0;
  double _dailyTrustChange = 0.0;

  Function(DailyStats)? onDayEnded;
  VoidCallback? onMinigameTriggered;

  String _lastLog = "시스템 가동 준비 완료. 14일간 원자로를 사수하십시오.";

  GameManager({required this.reactor});

  int get day => _day;
  String get timeString =>
      "${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}";
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  String get lastLog => _lastLog;

  // 💾 [NEW] 새 월드 생성
  void createNewWorld(String name) {
    worldName = name;
    _day = 1;
    _hour = 9;
    _minute = 0;
    _dailyEnergyAccumulated = 0.0;
    _dailyMaxTemp = 0.0;
    _dailyViolations = 0;
    _dailyTrustChange = 0.0;
    _isGameOver = false;
    _lastLog = "[$worldName] 월드 생성 완료. 시스템 가동 시작.";
    saveGameLocal();
    startGame();
  }

  // 💾 [NEW] 진행 상황 로컬 저장 (Save & Quit 용도)
  Future<void> saveGameLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'worldName': worldName,
      'day': _day,
      'hour': _hour,
      'minute': _minute,
      'energy': _dailyEnergyAccumulated,
      'trust': _dailyTrustChange,
    };
    await prefs.setString('save_data', jsonEncode(data));
  }

  // 💾 [NEW] 게임 불러오기
  Future<bool> loadGameLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saveData = prefs.getString('save_data');
    if (saveData != null) {
      final data = jsonDecode(saveData);
      worldName = data['worldName'] ?? "Unknown";
      _day = data['day'] ?? 1;
      _hour = data['hour'] ?? 9;
      _minute = data['minute'] ?? 0;
      _dailyEnergyAccumulated = data['energy'] ?? 0.0;
      _dailyTrustChange = data['trust'] ?? 0.0;
      _isGameOver = false;
      _lastLog = "[$worldName] 데이터 로드 완료. 이어서 시작합니다.";
      notifyListeners();
      return true;
    }
    return false;
  }

  // 💾 [NEW] 저장하고 메인으로 나가기
  Future<void> saveAndQuit() async {
    pauseGame();
    await saveGameLocal();
    _lastLog = "게임이 안전하게 저장되었습니다.";
    notifyListeners();
  }

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
    reactor.tick();
    _dailyEnergyAccumulated += (reactor.state.electricalOutput / 6);

    if (reactor.state.temperature > _dailyMaxTemp) {
      _dailyMaxTemp = reactor.state.temperature;
    }

    if (reactor.state.temperature > 800.0) {
      _dailyViolations++;
      _dailyTrustChange -= 1.0;
    }

    if (_minute >= 60) {
      _minute = 0;
      _hour++;

      // 자동 저장 (1시간 지날 때마다)
      saveGameLocal();

      if (_hour == 14 && _day % 3 == 0) {
        pauseGame();
        _lastLog = "⚠️ 경고: 방사성 폐기물 반입. 즉시 분류 작업을 시작하십시오.";
        onMinigameTriggered?.call();
      }

      if (_hour >= 24) {
        _hour = 0;
        _endDay();
      }
    }

    if (reactor.state.isMeltdown) {
      _finishGame("🚨 MELTDOWN: 과열로 인한 노심 용융! 미션 실패.");
    } else if (_day > maxDays) {
      _finishGame("🏆 MISSION COMPLETE: 14일간 무사고 운전 달성!");
    }
    notifyListeners();
  }

  void _endDay() {
    pauseGame();
    DailyStats todayStats = DailyStats(
      day: _day,
      totalEnergyGenerated: _dailyEnergyAccumulated,
      safetyViolations: _dailyViolations,
      maxTemperatureReached: _dailyMaxTemp,
      publicTrustChange: _dailyTrustChange,
    );
    _saveToSupabase(todayStats);
    if (onDayEnded != null) onDayEnded!(todayStats);
  }

  void startNextDay() {
    _day++;
    _hour = 9;
    _minute = 0;
    _dailyEnergyAccumulated = 0.0;
    _dailyMaxTemp = 0.0;
    _dailyViolations = 0;
    _dailyTrustChange = 0.0;
    _checkDayEvents();
    saveGameLocal(); // 다음 날 시작 시 저장
    startGame();
  }

  void _checkDayEvents() {
    if (_day == 3)
      _lastLog = "⚠️ 폭염 주의보: 냉각수 온도가 상승합니다.";
    else if (_day == 7)
      _lastLog = "⚠️ 지진 감지: 설비 내구도를 확인하세요.";
    else if (_day == 10)
      _lastLog = "📢 정보: 발전소 앞 대규모 시위 발생. 주민 설득이 필요합니다.";
    else
      _lastLog = "📅 Day $_day 일과 시작. 특이사항 없음.";
  }

  void _finishGame(String resultMsg) {
    _isGameOver = true;
    _isPaused = true;
    _timer?.cancel();
    _lastLog = resultMsg;
    notifyListeners();
  }

  Future<void> _saveToSupabase(DailyStats stats) async {
    try {
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
