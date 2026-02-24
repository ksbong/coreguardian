import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// 폴더 구조에 맞게 import
import 'features/simulation/logic/reactor_provider.dart';
import 'features/simulation/logic/game_manager.dart';
import 'screens/main_game_screen.dart';

// 새로 추가한 인증 화면 (경로는 파일 만든 위치에 맞게 수정해줘)
import 'features/auth/auth_screen.dart';

void main() async {
  // Flutter 엔진과 프레임워크가 제대로 바인딩되었는지 확인 (비동기 초기화 전 필수)
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zdjpqbdvyjljazmtbmob.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkanBxYmR2eWpsamF6bXRibW9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1NzM4MDEsImV4cCI6MjA4NzE0OTgwMX0.jBuTadA31-INoJ4qDI9nCASgKv8EEHbC2ldtSxfjRdM',
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. 물리 엔진 코어 생성
        ChangeNotifierProvider(create: (_) => ReactorProvider()),

        // 2. 게임 매니저 생성 (물리 엔진 상태를 주입받아서 규제/생존 검사)
        ChangeNotifierProxyProvider<ReactorProvider, GameManager>(
          create: (ctx) => GameManager(reactor: ctx.read<ReactorProvider>()),
          update: (ctx, reactor, prev) => GameManager(reactor: reactor),
        ),
      ],
      child: const CoreGuardianApp(),
    ),
  );
}

class CoreGuardianApp extends StatelessWidget {
  const CoreGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statera Reactor',
      // 전체적인 앱 테마를 다크 모드로 설정하고 폰트 통일
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.notoSansKrTextTheme(ThemeData.dark().textTheme),
      ),

      // Supabase의 인증 상태(로그인/로그아웃) 변화를 실시간으로 감지
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // 로딩 중일 때 보여줄 화면
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              ),
            );
          }

          final session = snapshot.data?.session;

          // 세션이 없으면(로그인 안 됨) 인증 화면으로, 있으면 게임 화면으로 보냄
          if (session == null) {
            return const AuthScreen();
          } else {
            return MainGameScreen();
          }
        },
      ),
    );
  }
}
