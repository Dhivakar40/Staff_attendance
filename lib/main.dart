import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_screen.dart';
import 'id_card_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? staffData = prefs.getString('staff_qr_data');
  runApp(MyApp(startScreen: staffData == null ? SetupScreen() : IdCardScreen()));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Staff ID',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: startScreen,
    );
  }
}