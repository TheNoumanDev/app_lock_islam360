import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/app_selection/screens/app_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (optional - can be removed if you want all orientations)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Can be changed to ThemeMode.system for auto dark mode
      home: const AppSelectionScreen(),
    );
  }
}
