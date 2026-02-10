import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class Reactor3DView extends StatefulWidget {
  final bool isInteractive;
  const Reactor3DView({super.key, this.isInteractive = false});

  @override
  State<Reactor3DView> createState() => _Reactor3DViewState();
}

class _Reactor3DViewState extends State<Reactor3DView> {
  final Flutter3DController _controller = Flutter3DController();

  // 🎛️ 카메라 설정값
  double _radius = 50.0; // 줌 거리
  double _theta = 30.0; // 가로 회전
  double _phi = 60.0; // 세로 각도

  // ⭐ 추가된 설정: 카메라 시선 높이 (모델 위치 보정용)
  // 이 값이 커질수록 모델이 화면 아래로 내려가고, 작아지면(마이너스) 위로 올라옴
  double _targetY = 0.0;

  final bool _showDebugControls = true;

  @override
  void initState() {
    super.initState();
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        _updateCamera();
      }
    });
  }

  void _updateCamera() {
    // 1. 먼저 카메라가 쳐다볼 높이(Target)를 설정 (X, Y, Z)
    _controller.setCameraTarget(0, _targetY, 0);
    // 2. 그 다음 카메라 위치(Orbit)를 설정
    _controller.setCameraOrbit(_theta, _phi, _radius);
  }

  @override
  Widget build(BuildContext context) {
    // Blender로 텍스처 포함해서 다시 저장한 파일 경로를 쓰세요.
    const String modelPath = 'assets/models/nuclear_city.glb';

    return Stack(
      children: [
        Container(
          color: const Color(0xFF14181F),
          child: Flutter3DViewer(
            controller: _controller,
            src: modelPath,
            progressBarColor: Colors.cyanAccent,
            enableTouch: false,
          ),
        ),

        if (_showDebugControls)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              width: 220, // 폭을 조금 늘림
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🔧 CAMERA DEBUG",
                    style: GoogleFonts.oswald(color: Colors.cyanAccent),
                  ),
                  const SizedBox(height: 10),

                  // 새로 추가된 슬라이더
                  _buildSlider(
                    "↕️ 시선 높이 (위/아래)",
                    _targetY,
                    -50,
                    50,
                    (v) => _targetY = v,
                  ),
                  const Divider(color: Colors.white24),
                  _buildSlider(
                    "🔍 Zoom (거리)",
                    _radius,
                    2,
                    500,
                    (v) => _radius = v,
                  ),
                  _buildSlider(
                    "🔄 Rotate (회전)",
                    _theta,
                    -180,
                    180,
                    (v) => _theta = v,
                  ),
                  _buildSlider("📐 Height (각도)", _phi, 0, 90, (v) => _phi = v),

                  const Divider(color: Colors.white24),
                  Text(
                    "Target Y: ${_targetY.toStringAsFixed(1)}\nOrbit($_theta, $_phi, $_radius)",
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double val,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    // (이전과 동일한 코드)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${val.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        SizedBox(
          height: 30,
          child: Slider(
            value: val,
            min: min,
            max: max,
            activeColor: Colors.cyanAccent,
            inactiveColor: Colors.grey,
            onChanged: (v) {
              setState(() {
                onChanged(v);
              });
              _updateCamera();
            },
          ),
        ),
      ],
    );
  }
}
