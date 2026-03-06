import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class Reactor3DView extends StatefulWidget {
  final bool isInteractive;
  const Reactor3DView({super.key, this.isInteractive = false});

  @override
  State<Reactor3DView> createState() => _Reactor3DViewState();
}

// 🚀 [NEW] 맥동하는 보호막 애니메이션을 위해 TickerProvider 추가
class _Reactor3DViewState extends State<Reactor3DView>
    with SingleTickerProviderStateMixin {
  final Flutter3DController _controller = Flutter3DController();

  final double _initialRadius = 25.0;
  final double _initialTheta = 45.0;
  final double _initialPhi = 55.0;
  final double _targetY = 2.0;

  final double _hitBoxWidth = 400.0;
  final double _hitBoxHeight = 350.0;

  bool _isHovering = false;
  Offset _mousePos = Offset.zero;
  Offset? _pointerDownPosition;

  // 🚀 [NEW] 보호막 애니메이션 컨트롤러
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        _controller.setCameraTarget(0, _targetY, 0);
        _controller.setCameraOrbit(_initialTheta, _initialPhi, _initialRadius);
      }
    });

    // 🚀 [NEW] 숨쉬듯 커졌다 작아지는 애니메이션 설정
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose(); // 🚀 [NEW] 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String modelPath = 'assets/models/nuclear.glb';

    return Stack(
      alignment: Alignment.center,
      children: [
        // 🚀 [NEW] 맥동하는 에너지 보호막 (3D 모델보다 뒤에 깔림)
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 350, // 보호막 크기 조절
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.1),
                      Colors.cyanAccent.withOpacity(0.0),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),

        // 1. 기존 제스처 감지기 & 3D 뷰어 (수정 없음)
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
              if (distance < 10) _handleClick();
            }
          },
          child: Flutter3DViewer(
            controller: _controller,
            src: modelPath,
            progressBarColor: Colors.cyanAccent,
            enableTouch: true,
          ),
        ),

        // 2. 호버링 라벨 (수정 없음)
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
    if (_isHovering != inside) setState(() => _isHovering = inside);
  }

  void _handleClick() {
    if (_isHovering && widget.isInteractive) {
      _showBouncingPopup(
        context,
        "원자로 통합 제어실",
        "시스템 상태: 정상 가동 중\n현재 출력: 98%\n노심 온도: 315°C\n\n[안전 수칙 준수 요망]",
      );
    }
  }

  void _showBouncingPopup(BuildContext context, String title, String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
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
        final curvedValue = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(scale: curvedValue, child: child);
      },
    );
  }
}
