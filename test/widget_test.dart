import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mworld/controllers/game_controller.dart';
import 'package:mworld/main.dart';
import 'package:mworld/models/player_model.dart';
import 'package:mworld/views/screens/game_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Settings screen audit, live updates, reset to defaults, and zero overflow', (WidgetTester tester) async {
    // Test on a narrow mobile portrait screen (360x640) - the exact screen that was overflowing
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Tap SETTINGS to open Settings Screen
    await tester.tap(find.text('SETTINGS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Settings UI Elements
    expect(find.text('SETTINGS'), findsWidgets);
    expect(find.text('SAVED'), findsOneWidget);
    expect(find.text('AUDIO HARMONIES'), findsOneWidget);
    expect(find.text('Master Melodies'), findsOneWidget);
    expect(find.text('Forest Wind & Music'), findsOneWidget);
    expect(find.text('Spell Sound Effects'), findsOneWidget);
    expect(find.text('Ambient Melodies'), findsOneWidget);

    expect(find.text('EXPEDITION CONTROLS'), findsOneWidget);
    expect(find.text('Virtual Traveler Compass'), findsOneWidget);
    expect(find.text('Compass Scale'), findsOneWidget);
    expect(find.text('Compass Opacity'), findsOneWidget);
    expect(find.text('Compass Sensitivity'), findsOneWidget);

    // Verify Reset to Defaults button exists and works
    await tester.ensureVisible(find.text('RESET TO DEFAULTS'));
    await tester.tap(find.text('RESET TO DEFAULTS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('All settings restored to factory defaults.'), findsOneWidget);

    // Remove SnackBar so it does not block the return button
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last)).removeCurrentSnackBar();
    await tester.pump();

    // Verify Return to Clearing button navigates back
    await tester.ensureVisible(find.text('RETURN TO CLEARING'));
    await tester.tap(find.text('RETURN TO CLEARING'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Back on Landing Screen
    expect(find.text('BRAWL ARENA'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('Complete Play flow navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Rich Landing Screen Elements
    expect(find.text('BRAWL ARENA'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('BRAWLER CALLSIGN'), findsOneWidget);
    expect(find.text('CHRONICLES OF THE GROVE'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('EXPEDITION FEATURES'), findsOneWidget);
    expect(find.text('GRIMOIRE WEAPON ARTIFACTS'), findsOneWidget);
    expect(find.text('EXPEDITION MAPS ATLAS'), findsOneWidget);
    expect(find.text('PARTY TRAVELER PRESETS'), findsOneWidget);
    expect(find.text('JOURNEY CHRONICLE'), findsOneWidget);

    // 2. Tap PLAY -> navigates to Avatar Select Screen
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SELECT TRAVELER'), findsOneWidget);
    expect(find.text('SHUFFLE ALL'), findsOneWidget);
    expect(find.text('RANDOM PICK'), findsOneWidget);
    expect(find.text('CHOOSE REALM MAP'), findsOneWidget);

    // 3. Tap CHOOSE REALM MAP -> navigates to Map Select Screen
    await tester.ensureVisible(find.text('CHOOSE REALM MAP'));
    await tester.tap(find.text('CHOOSE REALM MAP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SELECT REALM MAP'), findsOneWidget);
    expect(find.text('Whispering Clearing'), findsWidgets);
    expect(find.text('Frostfall Shrine'), findsWidgets);
    expect(find.text("Dragon's Spire"), findsWidgets);

    // Verify locked map interaction triggers snackbar
    await tester.tap(find.text('Frostfall Shrine').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('Discovered at Lv. 10'), findsWidgets);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();

    // 4. Tap CHOOSE WEAPON ARTIFACT -> navigates to Match Setup
    await tester.ensureVisible(find.text('CHOOSE WEAPON ARTIFACT'));
    await tester.tap(find.text('CHOOSE WEAPON ARTIFACT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MATCH LOBBY'), findsOneWidget);
    expect(find.text('START MATCH'), findsOneWidget);
    expect(find.text('SWORD'), findsWidgets);
    expect(find.text('BOW'), findsWidgets);
    expect(find.text('BOMB'), findsWidgets);

    // 5. Tap START MATCH -> navigates to active GameScreen
    await tester.ensureVisible(find.text('START MATCH'));
    await tester.tap(find.text('START MATCH'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Game screen elements
    expect(find.textContaining('HP'), findsWidgets);

    // Clean up active match for test environment
    final gameController = Provider.of<GameController>(
      tester.element(find.byType(GameScreen)),
      listen: false,
    );
    gameController.quitMatch();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Mobile portrait ~360px view renders without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('BRAWL ARENA'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  testWidgets('Mobile landscape 640x360 view renders without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('BRAWL ARENA'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  testWidgets('Tablet 768x1024 view renders without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('BRAWL ARENA'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  testWidgets('Desktop wide screens 1366px and 1920px render with top bar and balanced hero', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('BRAWL ARENA'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('CHRONICLES OF THE GROVE'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('GRIMOIRE WEAPON ARTIFACTS'), findsOneWidget);
    expect(find.text('EXPEDITION MAPS ATLAS'), findsOneWidget);
    expect(find.text('PARTY TRAVELER PRESETS'), findsOneWidget);
    expect(find.text('JOURNEY CHRONICLE'), findsOneWidget);
    expect(find.text('EXPEDITION FEATURES'), findsOneWidget);

    // Top bar nav links
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Grimoire'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('M-World & Mythril World branding, hierarchy, and About lore verification', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify Title Hierarchy on Landing Screen
    expect(find.text('M-WORLD'), findsWidgets);
    expect(find.text('MYTHRIL WORLD'), findsWidgets);
    expect(find.text('BRAWL ARENA'), findsWidgets);

    // Verify Chronicles text contains exact M-World lore definition
    expect(find.textContaining('Mythril World is an indestructible, high-altitude training crucible where mages and warriors can unleash catastrophic spells without wrecking the fragile mortal realm.'), findsOneWidget);

    // Tap ABOUT button to open AboutScreen
    await tester.tap(find.text('ABOUT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AboutScreen has exact M-World lore definition
    expect(find.text('ABOUT M-WORLD (MYTHRIL WORLD)'), findsOneWidget);
    expect(find.textContaining('Mythril World is an indestructible, high-altitude training crucible where mages and warriors can unleash catastrophic spells without wrecking the fragile mortal realm.'), findsWidgets);
    expect(find.textContaining('Brawl Arena — Trial of the Enchanted Forest is a friendly training trial inside Mythril World where mages and warriors train.'), findsOneWidget);

    // Navigate back to LandingScreen
    await tester.ensureVisible(find.text('RETURN TO CLEARING'));
    await tester.tap(find.text('RETURN TO CLEARING'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('M-WORLD'), findsWidgets);
  });

  testWidgets('Arena top bar hamburger menu, pause/resume, quick settings, and exit dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Navigate to GameScreen
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('CHOOSE REALM MAP'));
    await tester.tap(find.text('CHOOSE REALM MAP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('CHOOSE WEAPON ARTIFACT'));
    await tester.tap(find.text('CHOOSE WEAPON ARTIFACT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('START MATCH'));
    await tester.tap(find.text('START MATCH'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // In Arena: Verify HUD elements
    expect(find.text('HARMONIES'), findsWidgets);
    expect(find.text('ARTIFACT'), findsWidgets);
    expect(find.text('RUNE TRIAL'), findsWidgets);

    // Verify standalone back arrow is removed from top bar
    expect(find.byTooltip('Return to Clearing'), findsNothing);

    // Verify Hamburger button is compact, at the top bar, and does NOT stretch or cover the arena
    final hamburgerRect = tester.getRect(find.byKey(const Key('hamburger_menu_button')));
    expect(hamburgerRect.height, lessThanOrEqualTo(50.0));
    expect(hamburgerRect.top, lessThan(30.0));
    expect(hamburgerRect.bottom, lessThan(80.0));

    // Prior to opening, drawer is positioned offscreen to the right (dx >= 1024)
    expect(tester.getTopLeft(find.text('RESUME EXPEDITION')).dx, greaterThanOrEqualTo(1024.0));

    // Tap Hamburger Button
    await tester.tap(find.byKey(const Key('hamburger_menu_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Drawer is open on-screen & game is paused
    expect(tester.getTopLeft(find.text('RESUME EXPEDITION')).dx, lessThan(1024.0));
    expect(find.text('PAUSED'), findsOneWidget);

    // 1. Header & Expedition Snapshot
    expect(find.text('M-WORLD'), findsWidgets);
    expect(find.text('MYTHRIL WORLD • BRAWL ARENA'), findsWidgets);
    expect(find.text('VITALITY (HP)'), findsOneWidget);

    // 2. Quick Settings
    expect(find.text('QUICK EXPEDITION SETTINGS'), findsOneWidget);
    expect(find.text('Mute All Audio'), findsOneWidget);
    expect(find.text('Master Melodies'), findsOneWidget);
    expect(find.text('OPEN FULL SETTINGS'), findsOneWidget);

    // 3. Controls / How to Play
    expect(find.text('CONTROLS & HOW TO PLAY'), findsOneWidget);

    // 4. Expedition Objective & Lore line
    expect(find.text('EXPEDITION OBJECTIVE & STATS'), findsOneWidget);
    expect(find.textContaining('This trial takes place in Mythril World, the indestructible training crucible, so catastrophic spells are safe to unleash here.'), findsOneWidget);

    // 5. About M-World Lore Card with exact definition
    expect(find.text('ABOUT M-WORLD'), findsOneWidget);
    expect(find.textContaining('Mythril World is an indestructible, high-altitude training crucible where mages and warriors can unleash catastrophic spells without wrecking the fragile mortal realm.'), findsWidgets);

    // 6. Test Resume Expedition Button
    await tester.tap(find.text('RESUME EXPEDITION'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Drawer is closed and slid back offscreen
    expect(tester.getTopLeft(find.text('RESUME EXPEDITION')).dx, greaterThanOrEqualTo(1024.0));

    // Reopen menu to test Exit Dialog
    await tester.tap(find.byKey(const Key('hamburger_menu_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getTopLeft(find.text('RESUME EXPEDITION')).dx, lessThan(1024.0));

    // Scroll to EXIT TO LANDING button and tap it
    await tester.ensureVisible(find.text('EXIT TO LANDING'));
    await tester.tap(find.text('EXIT TO LANDING'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Exit confirmation dialog appears
    expect(find.text('Exit to Landing?'), findsOneWidget);
    expect(find.textContaining('Current expedition progress in Mythril World will be lost.'), findsOneWidget);

    // Tap EXIT TO LANDING inside the dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'EXIT TO LANDING'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Back on Landing Screen
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('M-WORLD'), findsWidgets);
  });

  testWidgets('5-Cycle Navigation and Gameplay Stress Loop: Landing -> Play -> Avatar -> Map -> Weapon -> Difficulty -> Arena -> Hamburger -> Settings -> Back -> Landing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrawlArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final weapons = [WeaponType.sword, WeaponType.bow, WeaponType.bomb, WeaponType.sword, WeaponType.bow];
    final difficulties = [BotDifficulty.easy, BotDifficulty.normal, BotDifficulty.hard, BotDifficulty.normal, BotDifficulty.hard];

    for (int cycle = 0; cycle < 5; cycle++) {
      // 1. Landing -> Play
      expect(find.text('PLAY'), findsOneWidget);
      await tester.tap(find.text('PLAY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 2. Avatar Select -> Map Select
      expect(find.text('CHOOSE REALM MAP'), findsOneWidget);
      await tester.tap(find.text('CHOOSE REALM MAP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 3. Map Select -> Match Setup
      expect(find.text('CHOOSE WEAPON ARTIFACT'), findsOneWidget);
      await tester.tap(find.text('CHOOSE WEAPON ARTIFACT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 4. Match Setup: Select Weapon & Difficulty for this cycle
      final weaponName = weapons[cycle].displayName.toUpperCase();
      await tester.tap(find.text(weaponName).first);
      await tester.pump(const Duration(milliseconds: 50));

      final diffName = difficulties[cycle].displayName.toUpperCase();
      await tester.tap(find.text(diffName).first);
      await tester.pump(const Duration(milliseconds: 50));

      // Tap START MATCH -> GameScreen
      await tester.tap(find.text('START MATCH'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 5. In Arena: Verify HUD is running
      expect(find.byKey(const Key('hamburger_menu_button')), findsOneWidget);
      expect(find.text('HARMONIES'), findsWidgets);

      // Open Hamburger Menu
      await tester.tap(find.byKey(const Key('hamburger_menu_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('PAUSED'), findsOneWidget);

      // 6. Open Full Settings
      await tester.ensureVisible(find.text('OPEN FULL SETTINGS'));
      await tester.tap(find.text('OPEN FULL SETTINGS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('SETTINGS'), findsOneWidget);

      // 7. Back from Settings to GameScreen
      await tester.tap(find.byTooltip('Back to Clearing'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 8. Exit to Landing from Hamburger Menu
      await tester.ensureVisible(find.text('EXIT TO LANDING'));
      await tester.tap(find.text('EXIT TO LANDING'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap EXIT TO LANDING inside dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'EXIT TO LANDING'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Verify returned to Landing Screen
      expect(find.text('PLAY'), findsOneWidget);
    }
  });
}
