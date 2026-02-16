import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/simulation/logic/reactor_provider.dart';

class SafetyMaintenanceScreen extends StatelessWidget {
  const SafetyMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B21),
        title: Text(
          "SAFETY MONITORING SYSTEM",
          style: GoogleFonts.oswald(color: Colors.white, letterSpacing: 1.2),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        elevation: 0,
      ),
      body: Consumer<ReactorProvider>(
        builder: (context, reactor, child) {
          final state = reactor.state;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 설명
                Text(
                  "DEFENSE IN DEPTH (심층 방어 현황)",
                  style: GoogleFonts.shareTechMono(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "다단계 방호 전략에 따라 각 방벽의 무결성을 점검하십시오.\n손상된 방벽은 즉시 보수가 필요합니다.",
                  style: GoogleFonts.notoSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                // 3중 방벽 카드 리스트
                Expanded(
                  child: ListView(
                    children: [
                      _buildBarrierCard(
                        context,
                        "제1방벽: 연료 피복관 (Fuel Cladding)",
                        "방사성 물질의 1차 저지선. 노심 용융 시 손상됨.",
                        state.fuelIntegrity,
                        Icons.local_fire_department,
                        () => reactor.repairBarrier('fuel'),
                      ),
                      _buildBarrierCard(
                        context,
                        "제2방벽: 원자로 용기 (Reactor Vessel)",
                        "고압을 견디는 강철 용기. 과도한 압력에 취약함.",
                        state.vesselIntegrity,
                        Icons.shield,
                        () => reactor.repairBarrier('vessel'),
                      ),
                      _buildBarrierCard(
                        context,
                        "제3방벽: 격납 건물 (Containment)",
                        "최후의 보루. 외부 충격 및 폭발 방지.",
                        state.containmentIntegrity,
                        Icons.domain,
                        () => reactor.repairBarrier('containment'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarrierCard(
    BuildContext context,
    String title,
    String description,
    double integrity,
    IconData icon,
    VoidCallback onRepair,
  ) {
    // 상태에 따른 색상 결정
    Color statusColor = Colors.greenAccent;
    String statusText = "STABLE";

    if (integrity < 30) {
      statusColor = Colors.redAccent;
      statusText = "CRITICAL";
    } else if (integrity < 70) {
      statusColor = Colors.orangeAccent;
      statusText = "WARNING";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: statusColor.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: statusColor, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.notoSans(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.shareTechMono(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 내구도 게이지
          Row(
            children: [
              Text(
                "INTEGRITY",
                style: GoogleFonts.shareTechMono(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: integrity / 100,
                    backgroundColor: Colors.black,
                    color: statusColor,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${integrity.toInt()}%",
                style: GoogleFonts.shareTechMono(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 수리 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.build_circle_outlined),
              label: const Text("긴급 유지보수 진행 (Repair)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.blueGrey),
              ),
              onPressed: integrity < 100 ? onRepair : null,
            ),
          ),
        ],
      ),
    );
  }
}
