import 'package:flutter/material.dart';
import 'reactor_provider.dart';

class GameManager extends ChangeNotifier {
  final ReactorProvider reactor;

  static const int maxDays = 30;
  int _day = 1;
  int _hour = 9; // 09:00 시작
  String _log = "게임 시작. 업무를 지시하세요.";

  GameManager({required this.reactor});

  int get day => _day;
  int get hour => _hour;
  String get log => _log;
  bool get isGameOver => _day > maxDays;

  // ⚡ 행동 수행 (Time Skip + Reactor Simulation)
  void performAction(String actionName, int costHours, VoidCallback onSuccess) {
    if (isGameOver) return;

    // 1. 퇴근 시간 체크
    if (_hour + costHours > 24) {
      _log = "시간 부족! 오늘은 퇴근해야 합니다.";
      notifyListeners();
      return;
    }

    // 2. 원자로 가속 시뮬레이션
    bool isSafe = reactor.simulateTimePass(costHours);

    if (!isSafe) {
      _log = "🚨 경고! $actionName 도중 사고 발생!";
      applyPenalty(3); // 3일 페널티
    } else {
      // 3. 무사하면 행동 수행
      onSuccess();
      _hour += costHours;
      _log = "$actionName 완료. (현재 $_hour시)";
    }
    notifyListeners();
  }

  void nextDay() {
    if (isGameOver) return;
    _day++;
    _hour = 9;
    _log = "$_day일차 업무 시작.";
    notifyListeners();
  }

  void applyPenalty(int days) {
    _day += days;
    _hour = 9;
    _log = "💥 사고 수습으로 $days일이 지났습니다...";
    reactor.reset();
    notifyListeners();
  }
}
