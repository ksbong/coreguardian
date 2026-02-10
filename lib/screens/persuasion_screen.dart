import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/game_manager.dart';
import '../features/persuasion/ui/dialogue_view.dart';

class PersuasionScreen extends StatelessWidget {
  const PersuasionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 임시 시나리오 데이터 (나중에 DB나 JSON으로 분리 추천)
    final data = {
      "npc": "지역 주민 대표",
      "text": "최근 지진 소식에 불안해서 잠을 못 자겠소! 원전이 안전하다는 증거가 있소?",
      "choices": [
        "내진 설계 기준인 0.3g(규모 7.0)를 견딥니다.", // 정답 (전문적 수치 제시)
        "걱정 마세요, 절대 안 무너집니다.", // 애매한 답변
        "사고 나면 대피하시면 됩니다." // 최악의 답변
      ],
      "correct": 0,
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B21),
        title: Text("주민 설득", style: GoogleFonts.oswald(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: DialogueView(
          npcName: data['npc'] as String,
          content: data['text'] as String,
          choices: data['choices'] as List<String>,
          onChoice: (index) {
            // ⚡ 3시간을 소모하며 설득 시도
            context.read<GameManager>().performAction("주민 설득", 3, () {
              // 3시간 동안 원자로가 안 터졌다면 이 콜백 실행
              if (index == data['correct']) {
                _showResult(context, "설득 성공", "주민들이 안심하고 돌아갔습니다.", Colors.green);
              } else {
                _showResult(context, "설득 실패", "주민들의 불안감이 증폭되었습니다...", Colors.red);
              }
            });
          },
        ),
      ),
    );
  }

  void _showResult(BuildContext context, String title, String msg, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // 팝업 닫기
              Navigator.pop(context); // 화면 닫기
            },
            child: const Text("복귀", style: TextStyle(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
  }
}