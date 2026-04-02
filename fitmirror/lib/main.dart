import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/avatar.dart';
import 'models/cloth_item.dart';
import 'models/tryon_result.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 注册适配器
  Hive.registerAdapter(AvatarAdapter());
  Hive.registerAdapter(ClothItemAdapter());
  Hive.registerAdapter(TryOnResultAdapter());

  // 打开盒子
  await Hive.openBox<Avatar>('avatars');
  await Hive.openBox<ClothItem>('clothes');
  await Hive.openBox<TryOnResult>('tryons');
  await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: FitMirrorApp(),
    ),
  );
}

class FitMirrorApp extends ConsumerStatefulWidget {
  const FitMirrorApp({super.key});

  @override
  ConsumerState<FitMirrorApp> createState() => _FitMirrorAppState();
}

class _FitMirrorAppState extends ConsumerState<FitMirrorApp> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 加载用户状态
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      ApiService.setToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FitMirror',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
