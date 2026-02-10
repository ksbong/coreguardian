import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/reactor_provider.dart';

class ReactorVisualizer extends StatelessWidget {
  const ReactorVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReactorProvider>().state;

    // 온도에 따른 색상 변화 (파랑 -> 빨강)
    final coreColor =
        Color.lerp(
          Colors.blueAccent,
          Colors.redAccent,
          (state.temperature - 300) / 700,
        ) ??
        Colors.blue;

    return Container(
      height: 250,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[800], // 원자로 격납 용기
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 4),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. 냉각수 (배경)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 200,
            decoration: BoxDecoration(
              color: coreColor.withValues(alpha: .5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
          ),

          // 2. 연료봉 (고정된 기둥들)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => Container(
                width: 20,
                height: 150,
                color: Colors.orange[900], // 우라늄 연료
              ),
            ),
          ),

          // 3. 제어봉 (위에서 내려옴)
          // controlRodLevel이 1.0이면 바닥까지 내려오고(흡수), 0.0이면 위로 올라감(가동)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  // 삽입률에 따라 높이 변화 (Visual Animation)
                  height: 50 + (state.controlRodLevel * 150),
                  decoration: BoxDecoration(
                    color: Colors.grey[400], // 제어봉 색상
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(5),
                    ),
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, color: Colors.black26),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 라벨
          const Positioned(
            bottom: 10,
            child: Text(
              "REACTOR CORE",
              style: TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
