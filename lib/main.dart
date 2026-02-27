import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wajba_client/firebase_options.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forcer orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WajbaApp());
}

class WajbaApp extends StatelessWidget {
  const WajbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Builder(
        builder: (context) {
          final auth   = context.watch<AuthProvider>();
          final router = AppRouter.router(auth);

          return MaterialApp.router(
            title:           WajbaStrings.appName,
            debugShowCheckedModeBanner: false,
            theme:           WajbaTheme.theme,
            routerConfig:    router,
            builder: (context, child) => MediaQuery(
              // Empêcher le texte de grandir avec les paramètres système
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
