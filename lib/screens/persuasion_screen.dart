import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 경로 주의 (상대 경로 사용)
import '../features/simulation/logic/game_manager.dart';
import '../features/persuasion/ui/dialogue_view.dart';

class PersuasionScreen extends StatelessWidget {
  const PersuasionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중에 logic 폴더로 분리 가능)
    final data = {
      "npc": "환경 운동가",
      "text": "원자력 발전소는 너무 위험하지 않나요?",
      "choices": ["안전 설비가 있습니다.", "위험하죠.", "저도 몰라요."],
      "correct": 0,
    };

    return Scaffold(
      appBar: AppBar(title: const Text("주민 설득 (3시간 소요)")),
      body: Center(
        child: DialogueView(
          npcName: data['npc'] as String,
          content: data['text'] as String,
          choices: data['choices'] as List<String>,
          onChoice: (index) {
            // ⚡ 핵심: 매니저를 통해 행동 수행
            context.read<GameManager>().performAction("주민 설득", 3, () {
              // 원자로가 안 터졌을 때만 실행되는 로직
              if (index == data['correct']) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("설득 성공!")));
                Navigator.pop(context); // 성공 시 복귀
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("설득 실패...")));
              }
            });
          },
        ),
      ),
    );
  }
}
