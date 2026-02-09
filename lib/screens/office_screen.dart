import 'package:flutter/material.dart';
import 'persuasion_screen.dart';

class OfficeScreen extends StatelessWidget {
  const OfficeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "EXTERNAL AFFAIRS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: Colors.white24),
        const SizedBox(height: 20),

        _buildNpcCard(
          context,
          "환경 운동가",
          "assets/npc_eco.png",
          "원전 반대 시위 중...",
          Colors.red,
        ),
        _buildNpcCard(
          context,
          "지역 상인회장",
          "assets/npc_merchant.png",
          "경제적 효과에 관심",
          Colors.orange,
        ),
        _buildNpcCard(
          context,
          "시청 공무원",
          "assets/npc_gov.png",
          "안전 보고서 요청",
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildNpcCard(
    BuildContext context,
    String name,
    String imgPath,
    String status,
    Color statusColor,
  ) {
    return Card(
      color: const Color(0xFF1E2126),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[800],
          child: const Icon(Icons.person, color: Colors.white),
        ), // 나중에 이미지로 교체
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(status, style: TextStyle(color: Colors.white54)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan.withOpacity(0.2),
            foregroundColor: Colors.cyanAccent,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersuasionScreen()),
            );
          },
          child: const Text("면담 요청 (3H)"),
        ),
      ),
    );
  }
}
