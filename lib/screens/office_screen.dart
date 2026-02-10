import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../features/simulation/logic/game_manager.dart';
import 'persuasion_screen.dart'; // 설득 화면으로 이동

class OfficeScreen extends StatelessWidget {
  const OfficeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final log = context.select((GameManager gm) => gm.lastLog);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ADMINISTRATION OFFICE",
            style: GoogleFonts.oswald(color: Colors.cyanAccent, fontSize: 24),
          ),
          const SizedBox(height: 10),

          // 최근 로그 표시창
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "📝 LOG: $log",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),

          // 업무 리스트
          Text(
            "AVAILABLE TASKS",
            style: GoogleFonts.oswald(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 10),

          _buildTaskCard(
            context,
            title: "주민 공청회 개최",
            subtitle: "지역 주민들의 불안감을 해소합니다. (3시간 소요)",
            icon: Icons.groups,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersuasionScreen(),
                ),
              );
            },
          ),

          _buildTaskCard(
            context,
            title: "안전 보고서 작성",
            subtitle: "규제 기관에 보고서를 제출합니다. (5시간 소요)",
            icon: Icons.description,
            onTap: () {
              // 즉시 수행 예시
              context.read<GameManager>().performAction("보고서 작성", 5, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("보고서 제출 완료! 신뢰도가 상승했습니다.")),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E2228),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
