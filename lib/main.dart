import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/cache/cache_service.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await CacheService.init();
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  assert(() {
    debugPrint('🚀 WAJBA — Env: ${envConfig.name} | API: ${envConfig.baseUrl}');
    return true;
  }());
  runApp(const ProviderScope(child: WajbaApp()));
}

class WajbaApp extends ConsumerWidget {
  const WajbaApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'WAJBA',
      debugShowCheckedModeBanner: envConfig.isDev,
      theme: WajbaTheme.light,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15)),
        ),
        child: child!,
      ),
    );
  }
}
