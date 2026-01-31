import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'engine/reactor_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(
    url: 'https://erepwheivpectdqksrxj.supabase.co',
    anonKey: 'sb_publishable_PTjYKW2CaDnMvMWaJQDMEg_ayQf_a_k',
  );

  // 엔진 시동
  ReactorEngine().start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Core Guardian',
      theme: ThemeData(brightness: Brightness.dark), // 원전 느낌나게 다크모드
      home: const ReactorControlPage(),
    );
  }
}

class ReactorControlPage extends StatefulWidget {
  const ReactorControlPage({super.key});

  @override
  State<ReactorControlPage> createState() => _ReactorControlPageState();
}

class _ReactorControlPageState extends State<ReactorControlPage> {
  final engine = ReactorEngine();
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    // 1초마다 setState를 호출해서 엔진의 변화를 화면에 반영
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CORE GUARDIAN SYSTEM"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상태 텍스트
            Text(
              engine.isScrammed
                  ? "🚨 SYSTEM HALTED (SCRAM)"
                  : "✅ NORMAL OPERATION",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: engine.isScrammed ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            // 실시간 수치 표시
            Text(
              "Reactor Temp: ${engine.temperature.toStringAsFixed(1)}°C",
              style: const TextStyle(fontSize: 32),
            ),
            Text(
              "Power Output: ${engine.power}%",
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "Decay Heat: ${engine.decayHeat.toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 50),
            // 긴급 정지 버튼
            ElevatedButton(
              onPressed: engine.isScrammed ? null : () => engine.scram(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
              ),
              child: const Text(
                "MANUAL SCRAM",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
