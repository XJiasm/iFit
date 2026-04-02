import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前底部导航页面索引 Provider
/// 0: Stage (展台)  1: Closet (资产)  2: Studio (创意)  3: Space (个人)
final currentTabIndexProvider = StateProvider<int>((ref) => 0);
