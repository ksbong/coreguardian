import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum WasteLevel { high, intermediate, low, veryLow, exempt }

class WasteItem {
  final String name;
  final double radioactivity; // Bq/g
  final bool heatGeneration; // 열 발생 여부
  final WasteLevel correctLevel;
  final String description;

  WasteItem(
    this.name,
    this.radioactivity,
    this.heatGeneration,
    this.correctLevel,
    this.description,
  );
}

class WasteMinigameScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WasteMinigameScreen({super.key, required this.onComplete});

  @override
  State<WasteMinigameScreen> createState() => _WasteMinigameScreenState();
}

class _WasteMinigameScreenState extends State<WasteMinigameScreen> {
  final List<WasteItem> pendingWaste = [
    WasteItem('사용후핵연료', 1000000.0, true, WasteLevel.high, '강한 방사선과 높은 붕괴열 발생'),
    WasteItem(
      '폐필터 및 이온교환수지',
      500.0,
      false,
      WasteLevel.intermediate,
      '원자로 냉각재 정화 계통에서 발생',
    ),
    WasteItem('사용한 작업복/장갑', 50.0, false, WasteLevel.low, '방사선 관리 구역 작업 시 착용'),
    WasteItem(
      '콘크리트 조각',
      0.5,
      false,
      WasteLevel.veryLow,
      '해체 작업 중 발생한 극저준위 폐기물',
    ),
    WasteItem(
      '일반 구역 청소 도구',
      0.05,
      false,
      WasteLevel.exempt,
      '규제 면제 수준 이하 (자체처분)',
    ),
  ];

  int score = 0;
  int strikes = 0;
  WasteItem? currentWaste;

  @override
  void initState() {
    super.initState();
    _nextWaste();
  }

  void _nextWaste() {
    if (pendingWaste.isEmpty) {
      _showResultDialog();
      return;
    }
    setState(() {
      currentWaste = pendingWaste.removeAt(0);
    });
  }

  void _checkClassification(WasteLevel selectedLevel) {
    if (currentWaste == null) return;

    if (currentWaste!.correctLevel == selectedLevel) {
      score += 20;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 정확한 분류입니다. (안전수칙 준수)'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      strikes++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 분류 오류! 원안위 고시 위반입니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _nextWaste();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          '폐기물 분류 작업 완료',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
        content: Text(
          '최종 정확도 점수: $score / 100\n규정 위반(오분류): $strikes 회\n\n결과는 여론 및 안전 점수에 반영됩니다.',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              widget.onComplete(); // GameManager로 복귀
              Navigator.pop(context); // 화면 자체를 닫기
            },
            child: const Text(
              '운전실 복귀',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2228),
      appBar: AppBar(
        title: Text(
          '방사성 폐기물 자체처분 기준 절차',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[900],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            if (currentWaste != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TARGET SCAN',
                      style: GoogleFonts.oswald(
                        color: Colors.cyanAccent,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                    const Divider(color: Colors.cyanAccent),
                    const SizedBox(height: 10),
                    Text(
                      currentWaste!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '방사능 농도: ${currentWaste!.radioactivity} Bq/g',
                      style: TextStyle(
                        color: currentWaste!.radioactivity > 400
                            ? Colors.redAccent
                            : Colors.yellow,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '열 발생 감지: ${currentWaste!.heatGeneration ? "DETECTED" : "NONE"}',
                      style: TextStyle(
                        color: currentWaste!.heatGeneration
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currentWaste!.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const Spacer(),
            Text(
              '화면 중앙의 아이콘을 하단의 알맞은 처분장으로 드래그 하십시오.',
              style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            if (currentWaste != null)
              Draggable<WasteLevel>(
                data: currentWaste!.correctLevel,
                feedback: Material(
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.delete_forever,
                    size: 100,
                    color: Colors.yellowAccent,
                  ),
                ),
                childWhenDragging: const Opacity(
                  opacity: 0.3,
                  child: Icon(
                    Icons.delete_forever,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                child: const Icon(
                  Icons.delete_forever,
                  size: 100,
                  color: Colors.yellow,
                ),
              ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDragTarget(
                    WasteLevel.high,
                    '고준위\n(심층)',
                    Colors.redAccent,
                  ),
                  _buildDragTarget(
                    WasteLevel.intermediate,
                    '중준위\n(천층)',
                    Colors.orangeAccent,
                  ),
                  _buildDragTarget(
                    WasteLevel.low,
                    '저준위\n(천층)',
                    Colors.yellowAccent,
                  ),
                  _buildDragTarget(
                    WasteLevel.veryLow,
                    '극저준위\n(매립)',
                    Colors.greenAccent,
                  ),
                  _buildDragTarget(
                    WasteLevel.exempt,
                    '자체처분\n(면제)',
                    Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragTarget(WasteLevel level, String label, Color color) {
    return DragTarget<WasteLevel>(
      onAcceptWithDetails: (details) {
        _checkClassification(level);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 75,
          height: 110,
          decoration: BoxDecoration(
            color: isHovering
                ? color.withValues(alpha: 0.6)
                : color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: isHovering ? 4 : 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}
