import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart'; // 패키지 사용
import 'package:google_fonts/google_fonts.dart';

class Reactor3DView extends StatelessWidget {
  const Reactor3DView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 여기에 네가 만든 3D 모델 파일(.glb)을 assets 폴더에 넣고 경로를 적으면 됨
    // 예: const String reactorModelPath = 'assets/models/reactor_core.glb';
    // const String reactorModelPath = '';
    const String reactorModelPath =
        'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

    return Stack(
      children: [
        // 1. 3D 뷰어 영역
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: reactorModelPath.isNotEmpty
              ? Flutter3DViewer(src: reactorModelPath)
              : Center(
                  // 모델 없을 때 보여줄 홀로그램 느낌의 대체 UI
                  child: Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.5),
                        width: 2,
                      ),
                      color: Colors.cyan.withOpacity(0.05),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.layers, size: 80, color: Colors.cyan),
                        const SizedBox(height: 20),
                        Text(
                          "NO 3D SIGNAL",
                          style: GoogleFonts.orbitron(
                            color: Colors.cyan,
                            fontSize: 20,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Load .glb model to visualize",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // 2. 오버레이 UI (정보 표시)
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTag("REACTOR VESSEL", Colors.white),
              const SizedBox(height: 5),
              _buildTag("STATUS: ACTIVE", Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: Colors.black54,
      ),
      child: Text(
        text,
        style: GoogleFonts.shareTechMono(color: color, fontSize: 12),
      ),
    );
  }
}
