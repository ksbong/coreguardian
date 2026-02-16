import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/game_manager.dart';
import '../features/simulation/logic/daily_stats.dart'; // 위에서 만든 파일 import

class DailyReportScreen extends StatefulWidget {
  final DailyStats stats;
  final VoidCallback onNextDay;

  const DailyReportScreen({
    super.key,
    required this.stats,
    required this.onNextDay,
  });

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  bool _quizSolved = false;
  bool _quizCorrect = false;

  // 📝 기획서 기반: 원자력 안전 상식 퀴즈 데이터 (예시)
  final Map<String, bool> _dailyQuiz = {
    "원자력 발전소의 '심층 방어'는 단일 고장이 사고로 이어지지 않게 하는 다중 보호 체계이다.": true,
    "제어봉(Control Rod)을 인출하면 핵분열 반응이 줄어들어 출력이 감소한다.": false, // 정답: 증가함
    "가압경수로(PWR)에서 냉각재는 감속재의 역할도 겸한다.": true,
  };

  late MapEntry<String, bool> _currentQuiz;

  @override
  void initState() {
    super.initState();
    // 랜덤 퀴즈 선정
    _currentQuiz = _dailyQuiz.entries
        .toList()[widget.stats.day % _dailyQuiz.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 500, // 보고서 너비 고정 (태블릿/PC 고려)
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white, // 종이 느낌
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 헤더
              Center(
                child: Column(
                  children: [
                    Text(
                      "DAILY OPERATION REPORT",
                      style: GoogleFonts.oswald(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      "REPORT NO. 2026-DAY-${widget.stats.day.toString().padLeft(2, '0')}",
                      style: GoogleFonts.shareTechMono(color: Colors.grey[700]),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                      height: 30,
                    ),
                  ],
                ),
              ),

              // 2. 운전 성과표
              _buildStatRow(
                "Total Energy Generated",
                "${widget.stats.totalEnergyGenerated.toStringAsFixed(1)} MWh",
              ),
              _buildStatRow(
                "Max Core Temp",
                "${widget.stats.maxTemperatureReached.toStringAsFixed(0)} °C",
              ),
              _buildStatRow(
                "Safety Violations",
                "${widget.stats.safetyViolations} Count(s)",
                isWarning: widget.stats.safetyViolations > 0,
              ),

              const SizedBox(height: 20),

              // 3. 등급 도장
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getGradeColor(widget.stats.grade),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "GRADE: ${widget.stats.grade}",
                    style: GoogleFonts.blackOpsOne(
                      color: _getGradeColor(widget.stats.grade),
                      fontSize: 40,
                    ),
                  ),
                ),
              ),

              const Divider(color: Colors.black54, height: 40),

              // 4. 오늘의 안전 퀴즈 (보너스)
              Text(
                "💡 SAFETY KNOWLEDGE CHECK",
                style: GoogleFonts.oswald(fontSize: 18, color: Colors.blueGrey),
              ),
              const SizedBox(height: 10),
              if (!_quizSolved) ...[
                Text(
                  _currentQuiz.key,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildQuizButton(true, "TRUE (O)")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildQuizButton(false, "FALSE (X)")),
                  ],
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: _quizCorrect ? Colors.green[100] : Colors.red[100],
                  child: Text(
                    _quizCorrect
                        ? "CORRECT! +Regulatory Budget Approved."
                        : "INCORRECT. Please review safety protocols.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _quizCorrect ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // 5. 다음 날 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.onNextDay,
                  child: Text("SIGN & PROCEED TO DAY ${widget.stats.day + 1}"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              color: isWarning ? Colors.red : Colors.black,
              fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizButton(bool answer, String text) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _quizSolved = true;
          _quizCorrect = (answer == _currentQuiz.value);
          // TODO: GameManager에 정답 보너스 적용 로직 추가 가능
        });
      },
      child: Text(text),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S':
        return Colors.purple;
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
