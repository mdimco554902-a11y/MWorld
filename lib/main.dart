import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/app_state_controller.dart';
import 'controllers/game_controller.dart';
import 'core/theme.dart';
import 'views/screens/about_screen.dart';
import 'views/screens/avatar_select_screen.dart';
import 'views/screens/game_screen.dart';
import 'views/screens/landing_screen.dart';
import 'views/screens/map_select_screen.dart';
import 'views/screens/match_setup_screen.dart';
import 'views/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrawlArenaApp());
}

/// Root Application Widget injecting MVC Controllers and configuring the Cozy High Fantasy theme.
class BrawlArenaApp extends StatelessWidget {
  const BrawlArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateController>(
          create: (_) => AppStateController(),
        ),
        ChangeNotifierProvider<GameController>(
          create: (_) => GameController(),
        ),
      ],
      child: MaterialApp(
        title: 'BRAWL ARENA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightMenuTheme,
        darkTheme: AppTheme.darkForestArenaTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingScreen(),
          '/avatar-select': (context) => const AvatarSelectScreen(),
          '/map-select': (context) => const MapSelectScreen(),
          '/match-setup': (context) => const MatchSetupScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/about': (context) => const AboutScreen(),
          '/game': (context) => const GameScreen(),
        },
      ),
    );
  }
}
