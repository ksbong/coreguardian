import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 폴더 구조에 맞게 import
import 'features/simulation/logic/reactor_provider.dart';
import 'features/simulation/logic/game_manager.dart';
import 'screens/main_game_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. 물리 엔진 생성
        ChangeNotifierProvider(create: (_) => ReactorProvider()),

        // 2. 게임 매니저 생성 (물리 엔진 주입)
        ChangeNotifierProxyProvider<ReactorProvider, GameManager>(
          create: (ctx) => GameManager(reactor: ctx.read<ReactorProvider>()),
          update: (ctx, reactor, prev) => GameManager(reactor: reactor),
        ),
      ],
      child: const MaterialApp(
        title: 'Statera Reactor',
        home: MainGameScreen(),
      ),
    ),
  );
}
