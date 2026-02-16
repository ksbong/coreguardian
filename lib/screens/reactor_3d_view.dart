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

  // ====================================================
  // 📐 [카메라 설정] 여기가 핵심!
  // 모델에 따라 이 숫자들을 조금씩 조절해서 최적의 뷰를 찾으세요.
  // ====================================================
  final double _initialRadius = 25.0; // 줌 (거리)
  final double _initialTheta = 45.0; // 가로 회전 (45도 대각선)
  final double _initialPhi = 55.0; // 세로 각도 (내려다보기)
  // ⭐ 모델이 너무 밑에 있으면 이 값을 키우세요 (예: 1.0 -> 2.0)
  final double _targetY = 2.0; // 카메라 시선 높이 보정

  // 🎯 [히트박스 설정] 중앙 인터랙션 영역 크기
  final double _hitBoxWidth = 400.0;
  final double _hitBoxHeight = 350.0;

  bool _isHovering = false;
  Offset _mousePos = Offset.zero;
  Offset? _pointerDownPosition;

  @override
  void initState() {
    super.initState();
    // 모델 로딩이 끝나면 설정한 카메라 각도로 즉시 이동
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        // 1. 시선 높이 조절 (모델 끌어올리기)
        _controller.setCameraTarget(0, _targetY, 0);
        // 2. 얼짱 각도로 세팅
        _controller.setCameraOrbit(_initialTheta, _initialPhi, _initialRadius);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const String modelPath = 'assets/models/nuclear.glb';

    return Stack(
      children: [
        // 1. 제스처 감지기 (Translucent로 통과시킴)
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: (event) {
            _checkHover(event.localPosition);
            setState(() => _mousePos = event.localPosition);
          },
          onPointerDown: (event) => _pointerDownPosition = event.localPosition,
          onPointerUp: (event) {
            if (_pointerDownPosition != null) {
              final distance =
                  (event.localPosition - _pointerDownPosition!).distance;
              if (distance < 10) {
                // 드래그가 아닌 클릭일 때만
                _handleClick();
              }
            }
          },
          child: Flutter3DViewer(
            controller: _controller,
            src: modelPath,
            progressBarColor: Colors.cyanAccent,
            enableTouch: true, // 회전 허용
          ),
        ),

        // 2. 호버링 라벨
        if (_isHovering && widget.isInteractive)
          Positioned(
            top: _mousePos.dy - 50,
            left: _mousePos.dx + 15,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyanAccent),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.settings_suggest,
                          color: Colors.cyanAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Core Guardian System",
                          style: GoogleFonts.oswald(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "클릭하여 상태 점검",
                      style: GoogleFonts.shareTechMono(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _checkHover(Offset localPos) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;
    final left = centerX - (_hitBoxWidth / 2);
    final right = centerX + (_hitBoxWidth / 2);
    final top = centerY - (_hitBoxHeight / 2);
    final bottom = centerY + (_hitBoxHeight / 2);

    bool inside =
        (localPos.dx >= left &&
        localPos.dx <= right &&
        localPos.dy >= top &&
        localPos.dy <= bottom);

    if (_isHovering != inside) {
      setState(() => _isHovering = inside);
    }
  }

  void _handleClick() {
    if (_isHovering && widget.isInteractive) {
      // 🚀 탱탱볼 애니메이션 팝업 호출
      _showBouncingPopup(
        context,
        "원자로 통합 제어실",
        "시스템 상태: 정상 가동 중\n현재 출력: 98%\n노심 온도: 315°C\n\n[안전 수칙 준수 요망]",
      );
    }
  }

  // 🎉 [NEW] 튕겨 나오는 애니메이션 팝업 함수
  void _showBouncingPopup(BuildContext context, String title, String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 바깥 클릭 시 닫힘
      barrierLabel: "Close",
      barrierColor: Colors.black54, // 배경 어둡게
      transitionDuration: const Duration(milliseconds: 400), // 애니메이션 속도 (0.4초)
      pageBuilder: (ctx, anim1, anim2) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2228),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.oswald(color: Colors.white)),
            ],
          ),
          content: Text(
            content,
            style: GoogleFonts.shareTechMono(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "확인",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        // 📈 elasticOut 곡선을 사용해서 띠용~ 하는 효과 주기
        final curvedValue = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue, // 0배에서 1배로 커지면서 튕김
          child: child,
        );
      },
    );
  }
}
